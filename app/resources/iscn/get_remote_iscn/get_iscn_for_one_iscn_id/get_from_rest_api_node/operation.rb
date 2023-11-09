# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

module Iscn::GetRemoteIscn::GetIscnForOneIscnId::GetFromRestApiNode
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      attribute(
        :iscn_id_prefix,
        contract: And[::String, Send[:present?]],
      )
      attribute(
        :iscn_version,
        contract: And[::String, Send[:present?]],
      )
      def iscn_id
        "#{iscn_id_prefix}/#{iscn_version}"
      end

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
      import_iscn_data

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

    def import_iscn_data
      unique_attrs = {
        iscn_id_prefix: inputs.iscn_id_prefix,
        version:        inputs.iscn_version,
      }
      # Don't spam API when unnecessary
      return unless Iscn::SequelModel.where(unique_attrs).empty?

      parsed_valid_iscn_data_entry.tap do |entry|
        Iscn::SequelModel.update_or_create(unique_attrs) do |rec|
          rec.set(
            iscn_id: inputs.iscn_id,

            owner: entry.owner,

            name: entry.data.contentMetadata.name,
            description: entry.data.contentMetadata.description,
            url: entry.data.contentMetadata.url,

            keywords: entry.data.contentMetadata.keywords.split(","),

            content_fingerprints: entry.data.contentFingerprints,

            ipld: entry.ipld,

            data: entry.data.to_h,
          )
        end
      end
    end

    memo_wise def parsed_valid_iscn_data_entry
      data = get_remote_data
      validation_result = ValidRepsonseContract.new.call(data)
      if validation_result.failure?
        puts validation_result.errors.to_h
        raise "response invalid"
      end
      result_hash = validation_result.to_h
      target_record_hash = result_hash.fetch(:records).find{|h| h.dig(:data, :recordVersion) == inputs.iscn_version}
      ValidSingleIscnRecordStruct.new(
        owner:  result_hash.fetch(:owner),

        ipld:   target_record_hash.fetch(:ipld),

        data:   target_record_hash.fetch(:data),
      )
    end

    def get_remote_data
      # https://docs.like.co/developer/likecoin-chain-api/rpc-api/useful-iscn-api
      response = http_client.get("/iscn/records/id", {
        iscn_id: inputs.iscn_id,
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
        required(:owner).filled(:string)
        required(:latest_version).filled(:string)

        required(:records).array(:hash) do
          required(:ipld).filled(:string)

          required(:data).hash do
            required(:@context).value(:hash)
            required(:@id).filled(:string)
            # This can be empty (tested)
            required(:contentFingerprints).value(:array).each(:str?)

            required(:contentMetadata).hash do
              # This can be empty (tested)
              optional(:name).value(:string)
              # This can be empty (tested)
              optional(:description).value(:string)
              # This can be empty (tested)
              optional(:url).value(:string)
              # This might be empty (guess)
              required(:keywords).value(:string)
            end

            # Just convert integer to string
            # Strangely `latest_version` contains string
            required(:recordVersion).value(Types::Coercible::String, :filled?)
          end
        end
      end
    end
    private_constant :ValidRepsonseContract

    class ValidSingleIscnRecordStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      # attributes cannot be defined with `@` prefix
      transform_keys do |k|
        next k unless k.start_with?("@")

        k.to_s.delete_prefix("@").to_sym
      end

      attribute :owner, Types::String

      attribute :ipld, Types::String

      attribute :data do
        attribute :id, Types::String
        attribute :contentFingerprints, Types::Array

        attribute :contentMetadata do
          attribute? :name, Types::String
          attribute? :description, Types::String
          attribute? :url, Types::String
          attribute :keywords, Types::String
        end

        attribute :recordVersion, Types::String
      end
    end
    private_constant :ValidSingleIscnRecordStruct

  end
end
