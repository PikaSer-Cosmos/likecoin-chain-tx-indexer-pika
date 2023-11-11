# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

module NftClasses::SyncAllRemoteClasses::GetFromRestApiNode
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      # attribute(
      #   :attr_name,
      #   contract: Any,
      #   refrigeration_mode: :none,
      #   refrigeration_mode: :shallow,
      # )
    end
    private_constant :Inputs

    class Result < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      # attribute(
      #   :attr_name,
      #   contract: Any,
      #   refrigeration_mode: :none,
      #   refrigeration_mode: :shallow,
      # )
    end
    private_constant :Result

    Contract Result
    def call
      import_all_classes

      Result.new
    end

    def self.call(...)
      new(...).call
    end

    def initialize(input_hash = {})
      super()
      @inputs = Inputs.new(input_hash)
    end

    private

    # region inputs

    Contract Inputs
    attr_reader :inputs

    # endregion inputs

    def import_all_classes
      all_classes.each do |entry|
        NftClass::SequelModel.update_or_create(class_id: entry.id) do |rec|
          rec.set(
            name: entry.name,
            symbol: entry.symbol,
            description: entry.description,
            uri: entry.uri,
            uri_hash: entry.uri_hash,

            metadata: entry.data.metadata,
            config: entry.data.config,

            parent_type: entry.data.parent.type,
            parent_iscn_id_prefix: entry.data.parent.iscn_id_prefix,
            parent_iscn_version_at_mint: entry.data.parent.iscn_version_at_mint,
            parent_account: entry.data.parent.account,
          )
        end
      end
    end

    memo_wise def all_classes
      classes = []
      next_key = nil

      loop do
        data = get_classes(next_key)
        validation_result = ValidResponseContract.new.call(data)
        raise "response invalid" if validation_result.failure?
        classes.concat(validation_result.to_h.fetch(:classes).map {|h| ValidSingleNftClassStruct.new(h) })
        next_key = ValidResponsePaginationDataStruct.new(validation_result.to_h[:pagination]).next_key
        break if next_key.nil?
      end

      classes
    end

    def get_classes(next_key)
      response = if next_key
        http_client.get("/cosmos/nft/v1beta1/classes", {
          # https://github.com/cosmos/cosmos-sdk/blob/v0.46.13/types/query/pagination.go#L69
          "pagination.key": next_key,
        })
      else
        http_client.get("/cosmos/nft/v1beta1/classes")
      end

      Oj.load(response.body)
    end

    memo_wise def http_client
      Faraday.new(ENV![:LIKECOIN_NODE_REST_API_BASE_URL].delete_suffix("/")) do |faraday|
        faraday.response :raise_error

        # Disable persistent to avoid `Errno::EMFILE - too many open files
        # https://honeyryderchuck.gitlab.io/httpx/wiki/Faraday-Adapter`
        faraday.adapter :httpx, persistent: false
      end
    end

    # /cosmos/nft/v1beta1/classes
    class ValidResponseContract < Dry::Validation::Contract
      json do
        required(:classes).array(:hash) do
          required(:id).filled(:string)
          # Even name can be empty...
          required(:name).value(:string)
          # Not sure what this is...
          required(:symbol).value(:string)
          # I think this can be blank string
          # But it could be auto filled (no idea)
          required(:description).value(:string)
          # This can be optional
          required(:uri).value(:string)
          # Only empty string observed a.t.m.
          required(:uri_hash).value(:string)
          required(:data).hash do
            required(:@type).filled(:string)

            required(:metadata).hash do
              # While object can be empty

              optional(:image).value(:string)
              optional(:external_url).value(:string)
              # Only empty string observed a.t.m.
              optional(:message).value(:string)
              # yes `nft_meta_collection_descrption` has a typo
              optional(:nft_meta_collection_id).value(:string)
              optional(:nft_meta_collection_name).value(:string)
              # We don't uses these yet
              # optional(:nft_meta_collection_descrption).value(:string)
            end

            required(:parent).hash do
              required(:type).filled(:string)
              required(:iscn_id_prefix).filled(:string)
              required(:iscn_version_at_mint).filled(:string)
              # Only empty string observed a.t.m.
              required(:account).value(:string)
            end

            required(:config).hash do
              required(:burnable).value(:bool)
              required(:max_supply).value(Dry::Schema::Types::Params::Integer, gteq?: 0)
              # No idea what's expected data type, only see `null`
              required(:blind_box_config)
            end

            required(:blind_box_state).hash do
              required(:content_count).value(Dry::Schema::Types::Params::Integer, gteq?: 0)
              required(:to_be_revealed).value(:bool)
            end
          end
        end
        required(:pagination).hash do
          required(:next_key).maybe(:string, :filled?)
          # Convert string to integer
          required(:total).value(Dry::Schema::Types::Params::Integer, gteq?: 0)
        end
      end
    end
    private_constant :ValidResponseContract

    class ValidResponsePaginationDataStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      attribute :next_key, Types::String.optional
      attribute :total, Types::Integer
    end
    private_constant :ValidResponsePaginationDataStruct

    class ValidSingleNftClassStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      attribute :id, Types::String
      attribute :name, Types::String
      attribute :symbol, Types::String
      attribute :description, Types::String
      attribute :uri, Types::String
      attribute :uri_hash, Types::String

      attribute :data do
        # Invalid name in ruby, plus it's unused
        # attribute :@type, Types::String

        attribute :metadata, Types::Hash

        attribute :parent do
          attribute :type, Types::String
          attribute :iscn_id_prefix, Types::String
          attribute :iscn_version_at_mint, Types::String
          attribute :account, Types::String
        end

        attribute :config, Types::Hash
      end
    end
    private_constant :ValidSingleNftClassStruct

  end
end
