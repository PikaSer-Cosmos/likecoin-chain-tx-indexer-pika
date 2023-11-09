# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :nfts do
      primary_key :id, type: "bigint"

      column :class_id, "text"
      column :nft_id, "text"
      # Denormalized column
      column :class_created_at, "timestamp"
      column :owner, "text"

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      unique [:class_id, :nft_id]

      index  [:class_created_at]
      index  [:owner]
      index  [:created_at]
      index  [:updated_at]
      index  [:nft_id]
    end
    # end
  end
end
