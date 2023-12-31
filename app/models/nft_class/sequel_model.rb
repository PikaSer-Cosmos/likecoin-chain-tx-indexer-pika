# frozen_string_literal: true

class NftClass::SequelModel < Sequel::Model(:nft_classes)
  # region associations

  many_to_one(
    :iscn,
    class: Iscn::SequelModel,
    # FK column in this table
    key: [:parent_iscn_id_prefix, :parent_iscn_version_at_mint],
    # FK column in associated table
    primary_key: [:iscn_id_prefix, :version],
  )

  # endregion associations

  dataset_module do
    def linked_with_thses_iscn_only(iscn_dataset)
      where(parent_iscn_id_prefix: iscn_dataset.select(:iscn_id_prefix))
    end

    def linked_with_these_nfts_only(nft_dataset)
      where(class_id: nft_dataset.select(:class_id))
    end

    def not_linked_with_these_nfts_only(nft_dataset)
      exclude(class_id: nft_dataset.select(:class_id))
    end

    def only_class_created_after(timestamp)
      where{class_created_at > timestamp}
    end

    def only_class_created_before(timestamp)
      where{class_created_at < timestamp}
    end


    # region nft_meta_collection_id related filtering

    def as_likerland_writing_nft_only
      where(Sequel.pg_jsonb_op(:metadata).contains({ nft_meta_collection_id: "likerland_writing_nft" }))
    end

    def as_nft_book_only
      where(Sequel.like(Sequel.pg_jsonb_op(:metadata).get_text("nft_meta_collection_id"), "%nft_book%"))
    end

    # endregion nft_meta_collection_id related filtering
  end

  # region setters

  def metadata=(v)
    return super unless v.is_a?(Hash)

    # `deep_stringify_keys` to avoid unnecessary updates
    super(v.deep_stringify_keys)
  end

  def config=(v)
    return super unless v.is_a?(Hash)

    # `deep_stringify_keys` to avoid unnecessary updates
    super(v.deep_stringify_keys)
  end

  # endregion setters
end

# Table: nft_classes
# Columns:
#  id                          | bigint                      | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  class_id                    | text                        | NOT NULL
#  parent_type                 | text                        |
#  parent_iscn_id_prefix       | text                        |
#  parent_iscn_version_at_mint | text                        |
#  parent_account              | text                        |
#  name                        | text                        |
#  symbol                      | text                        |
#  description                 | text                        |
#  uri                         | text                        |
#  uri_hash                    | text                        |
#  metadata                    | jsonb                       |
#  config                      | jsonb                       |
#  class_created_at            | timestamp without time zone |
# Indexes:
#  nft_classes_pkey                        | PRIMARY KEY btree (id)
#  nft_classes_class_id_key                | UNIQUE btree (class_id)
#  nft_classes_class_created_at_index      | btree (class_created_at) WHERE class_created_at IS NOT NULL
#  nft_classes_class_id_index              | btree (class_id)
#  nft_classes_parent_iscn_id_prefix_index | btree (parent_iscn_id_prefix)
