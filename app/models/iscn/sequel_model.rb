# frozen_string_literal: true

class Iscn::SequelModel < Sequel::Model(:iscn)
  dataset_module do
    def with_owner_only(owner)
      # Just convert to array first, single or multiple
      all_owner_values = Array(owner).flat_map do |maybe_addr|
        Cosmos::Account::Addresses::ConvertOneAddressToManyVariants::Operation.call(address: maybe_addr).addresses
      end

      where(owner: all_owner_values)
    end
  end

  # region setters

  def data=(v)
    return super unless v.is_a?(Hash)

    # `deep_stringify_keys` to avoid unnecessary updates
    super(v.deep_stringify_keys)
  end

  # endregion setters
end

# Table: iscn
# Columns:
#  id                   | bigint | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  iscn_id              | text   |
#  iscn_id_prefix       | text   |
#  version              | text   |
#  owner                | text   |
#  name                 | text   |
#  description          | text   |
#  url                  | text   |
#  keywords             | text[] |
#  content_fingerprints | text[] |
#  ipld                 | text   |
#  data                 | jsonb  |
# Indexes:
#  iscn_pkey                         | PRIMARY KEY btree (id)
#  iscn_iscn_id_key                  | UNIQUE btree (iscn_id)
#  iscn_iscn_id_prefix_version_key   | UNIQUE btree (iscn_id_prefix, version)
#  iscn_content_fingerprints_index   | gin (content_fingerprints)
#  iscn_iscn_id_prefix_version_index | btree (iscn_id_prefix, version)
#  iscn_keywords_index               | gin (keywords)
#  iscn_owner_index                  | btree (owner)
