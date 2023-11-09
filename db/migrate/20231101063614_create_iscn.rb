# frozen_string_literal: true

Sequel.migration do
  change do

    create_table :iscn do
      primary_key :id, type: "bigint"

      column :iscn_id, "text"
      column :iscn_id_prefix, "text"
      column :version, "text"

      column :owner, "text"

      column :name, "text"
      column :description, "text"
      column :url, "text"
      column :keywords, "text[]"
      column :content_fingerprints, "text[]"
      column :ipld, "text"
      column :data, "jsonb"

      unique [:iscn_id]
      unique [:iscn_id_prefix, :version]

      index [:owner]
      index [:keywords], type: :gin
      index [:content_fingerprints], type: :gin
    end

  end
end
