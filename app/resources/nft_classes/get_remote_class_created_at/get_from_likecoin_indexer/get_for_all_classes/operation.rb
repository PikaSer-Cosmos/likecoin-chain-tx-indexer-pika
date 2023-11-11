# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

module NftClasses::GetRemoteClassCreatedAt::GetFromLikecoinIndexer::GetForAllClasses
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
        NftClass::SequelModel.where(class_id: entry.id).first&.tap do |rec|
          rec.update(class_created_at: entry.created_at)
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
        http_client.get("/likechain/likenft/v1/class", {
          # https://github.com/cosmos/cosmos-sdk/blob/v0.46.13/types/query/pagination.go#L69
          "pagination.key": next_key,
        })
      else
        http_client.get("/likechain/likenft/v1/class")
      end

      Oj.load(response.body)
    end

    memo_wise def http_client
      # `/likechain/likenft/v1/class` is only available on this API
      Faraday.new("https://mainnet-node.like.co") do |faraday|
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
          required(:created_at).filled(:string)
        end
        required(:pagination).hash do
          optional(:next_key).maybe(:integer)
          optional(:total).value(:integer, gteq?: 0)
        end
      end
    end
    private_constant :ValidResponseContract

    class ValidResponsePaginationDataStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      attribute? :next_key, Types::Integer
      attribute? :total, Types::Integer
    end
    private_constant :ValidResponsePaginationDataStruct

    class ValidSingleNftClassStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      attribute :id, Types::String
      attribute :created_at, Types::String
    end
    private_constant :ValidSingleNftClassStruct

  end
end
