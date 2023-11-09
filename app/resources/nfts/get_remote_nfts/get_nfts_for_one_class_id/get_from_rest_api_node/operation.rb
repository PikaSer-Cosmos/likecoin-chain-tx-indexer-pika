# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

require "parallel"

module Nfts::GetRemoteNfts::GetNftsForOneClassId::GetFromRestApiNode
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      attribute(
        :class_id,
        contract: And[::String, Send[:present?]],
      )

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
      import_nft_data

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

    def import_nft_data
      Parallel.map(parsed_valid_nfts_data_entries, in_threads: 2) do |entry|
        Nft::SequelModel.update_or_create(
          class_id: entry.class_id,
          nft_id:   entry.id,
        ) do |rec|
          # Nothing extra to set a.t.m.
          #
          # rec.set(
          #   attr: value,
          # )
        end
      end
    end

    memo_wise def parsed_valid_nfts_data_entries
      data = get_remote_nft_data
      validation_result = ValidRepsonseContract.new.call(data)
      if validation_result.failure?
        puts validation_result.errors.to_h
        raise "response invalid"
      end
      result_hash = validation_result.to_h
      result_hash.fetch(:nfts).filter_map do |data_hash|
        ValidSingleNftStruct.new(data_hash)
      end
    end

    def get_remote_nft_data
      # https://docs.like.co/developer/likenft/api-reference#nfts
      response = http_client.get("/cosmos/nft/v1beta1/nfts", {
        class_id: inputs.class_id,
      })

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
    class ValidRepsonseContract < Dry::Validation::Contract
      module Types
        include Dry.Types()
      end

      json do
        required(:nfts).array(:hash) do
          required(:class_id).filled(:string)
          required(:id).filled(:string)
          # This can be empty (tested)
          required(:uri).value(:string)
          # Empty as usual
          required(:uri_hash).value(:string)
        end
      end
    end
    private_constant :ValidRepsonseContract

    class ValidSingleNftStruct < ::Dry::Struct
      prepend ::MemoWise

      module Types
        include Dry.Types()
      end

      # attributes cannot be defined with `@` prefix
      transform_keys do |k|
        next k unless k.start_with?("@")

        k.to_s.delete_prefix("@").to_sym
      end

      attribute :class_id, Types::String
      attribute :id, Types::String
      attribute :uri, Types::String
      attribute :uri_hash, Types::String
    end
    private_constant :ValidSingleNftStruct

  end
end
