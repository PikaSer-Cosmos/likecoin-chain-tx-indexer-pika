Sequel.migration do
  change do

    # region this project's data structure

    create_table :nft_classes do
      primary_key :id, type: "bigint"

      # This data cannot be missed, NOT NULL
      column :class_id, "text", null: false, unique: true

      column :parent_type, "text"
      column :parent_iscn_id_prefix, "text"
      column :parent_iscn_version_at_mint, "text"
      column :parent_account, "text"

      column :name, "text"
      column :symbol, "text"
      column :description, "text"
      column :uri, "text"
      column :uri_hash, "text"
      column :metadata, "jsonb"
      column :config, "jsonb"
      # column :price, "integer"
      column :class_created_at, "timestamp"

      # Don't care about price yet
      #
      # # If price unknown, set as `null` instead of `0`...
      # column :latest_price, "bigint"#, default: 0
      # column :price_updated_at, "timestamp"

      index [:parent_iscn_id_prefix]
      index [:class_created_at]
    end

    # create_table :txs do
    #   primary_key :id, type: "bigint"
    #
    #   column :height, "bigint", null: false
    #   # column :tx_index, "integer"
    #   column :tx_response, "jsonb"
    #   # Instead of `tx_index` (which won't appear if transactions queried via event type)
    #   column :txhash, "text", null: false
    #   # In form of `eventType.eventAttribute='attributeValue'`
    #   # For the logs.events (not the one with encrypted attribute key/value)
    #   column :events, "text[]"
    #
    #   unique [:height, :txhash]
    #
    #   index [:height, :txhash]
    #   index [:events], type: :gin
    # end

    # create_table :nft_class_events do
    #   primary_key :id, type: "bigint"
    #
    #   column :class_id, "text", null: false
    #   column :on_chain_event_type, "text", null: false
    #
    #   column :txhash, "text", null: false
    #
    #   column :tx_timestamp, "timestamp", null: false
    #
    #   column :sender, "text", null: false
    #
    #   index [:class_id, :on_chain_event_type]
    # end

    # endregion this project's data structure

    # region data structure from likecoin-chain-tx-indexer

    # create_table :txs do
    #   primary_key :id, type: "bigint"
    #
    #   column :height, "bigint"
    #   column :tx_index, "integer"
    #   column :tx, "jsonb"
    #   column :events, "text[]"
    #
    #   unique [:height, :tx_index]
    #
    #   index [:height, :tx_index]
    #   index [:events], type: :gin
    # end
    #
    # # Sequel can't handle expression when adding index
    # # run %Q|CREATE INDEX IF NOT EXISTS idx_txs_txhash ON txs USING HASH ((tx->>'txhash'))|
    #
    # create_table :iscn do
    #   primary_key :id, type: "bigint"
    #
    #   column :iscn_id, "text"
    #   column :iscn_id_prefix, "text"
    #   column :version, "integer"
    #   column :owner, "text"
    #   column :name, "text"
    #   column :description, "text"
    #   column :url, "text"
    #   column :keywords, "text[]"
    #   column :fingerprints, "text[]"
    #   column :ipld, "text"
    #   column :timestamp, "timestamp"
    #   # Dropped later
    #   # column :stakeholders, "jsonb"
    #   column :data, "jsonb"
    #
    #   unique [:iscn_id]
    #
    #   index [:owner]
    #   index [:keywords], type: :gin
    #   index [:fingerprints], type: :gin
    #   index [:iscn_id_prefix]
    # end
    #
    # create_table :meta do
    #   column :id, "text", primary_key: true
    #
    #   column :integer_value, "bigint"
    # end
    #
    # create_table :nft_class do
    #   primary_key :id, type: "bigint"
    #
    #   column :class_id, "text", unique: true
    #   column :parent_type, "text"
    #   column :parent_iscn_id_prefix, "text"
    #   column :parent_account, "text"
    #   column :name, "text"
    #   column :symbol, "text"
    #   column :description, "text"
    #   column :uri, "text"
    #   column :uri_hash, "text"
    #   column :metadata, "jsonb"
    #   column :config, "jsonb"
    #   column :price, "integer"
    #   column :created_at, "timestamp"
    #
    #   column :latest_price, "bigint", default: 0
    #   column :price_updated_at, "timestamp"
    #
    #   index [:parent_iscn_id_prefix]
    #   index [:class_id]
    # end
    #
    # create_table :nft do
    #   primary_key :id, type: "bigint"
    #
    #   column :class_id, "text"
    #   column :owner, "text"
    #   column :nft_id, "text"
    #   column :uri, "text"
    #   column :uri_hash, "text"
    #   column :metadata, "jsonb"
    #
    #   column :latest_price, "bigint", default: 0
    #   column :price_updated_at, "timestamp"
    #
    #   unique [:class_id, :nft_id]
    #
    #   index  [:owner]
    #   index  [:class_id]
    # end
    #
    # create_table :nft_event do
    #   primary_key :id, type: "bigint"
    #
    #   column :action, "text"
    #   column :class_id, "text"
    #   column :nft_id, "text"
    #   column :sender, "text"
    #   column :receiver, "text"
    #   column :events, "text[]"
    #   column :tx_hash, "text"
    #   column :timestamp, "timestamp"
    #
    #   column :price, "bigint"
    #   column :memo, "text", default: "", null: false
    #   column :iscn_owner_at_the_time, "text", default: "", null: false
    #
    #   unique [:action, :class_id, :nft_id, :tx_hash]
    #
    #   index [:sender]
    #   index [:action]
    #   index [:receiver]
    #   index [:nft_id, :receiver]
    #   index [:class_id]
    #   index [:iscn_owner_at_the_time]
    # end
    #
    # create_table :iscn_stakeholders do
    #   # -- pid means primary key ID, which is the auto-increment ID assigned by database in `iscn` table
    #   foreign_key :iscn_pid, :iscn, key: :id
    #   # -- stakeholder's ID, `sid` so not to be ambiguous with `id` column in `iscn` table
    #   column :sid, "text"
    #   # -- stakeholder's name, `sname` so not to be ambiguous with `name` column in `iscn` table
    #   column :sname, "text"
    #   # -- raw stakeholder object
    #   column :data, "jsonb"
    #
    #   index [:sid, :iscn_pid]
    #   index [:sname, :iscn_pid]
    #   index [:iscn_pid]
    # end
    #
    # create_table :iscn_latest_version do
    #   column :iscn_id_prefix, "text", primary_key: true
    #
    #   column :latest_version, "integer"
    # end
    #
    # create_table :nft_marketplace do
    #   column :type, "text"
    #   column :class_id, "text"
    #   column :nft_id, "text"
    #   column :creator, "text"
    #   column :price, "bigint"
    #   column :expiration, "timestamp"
    #
    #   primary_key [:type, :class_id, :nft_id, :creator]
    #
    #   index [
    #     :type,
    #     :class_id,
    #     :expiration,
    #     :price,
    #   ]
    #   index [
    #     :type,
    #     :nft_id,
    #     :class_id,
    #     :expiration,
    #     :price,
    #   ]
    #   index [
    #     :type,
    #     :creator,
    #     :expiration,
    #     :price,
    #   ]
    # end
    #
    # create_table :nft_income do
    #   primary_key :id, type: "bigint"
    #
    #   column :class_id, "text", null: false
    #   column :nft_id, "text", null: false
    #   column :tx_hash, "text", null: false
    #   column :address, "text", null: false
    #   column :amount, "bigint", null: false
    #
    #   column :is_royalty, "boolean", default: true, null: false
    #
    #   unique [:class_id, :nft_id, :tx_hash, :address]
    #
    #   index [:class_id]
    #   index [:address]
    # end

    # endregion data structure from likecoin-chain-tx-indexer

  end
end
