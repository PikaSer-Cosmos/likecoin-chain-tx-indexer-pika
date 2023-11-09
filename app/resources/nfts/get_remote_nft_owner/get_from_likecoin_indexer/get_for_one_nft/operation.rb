# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

module Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForOneNft
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      attribute(
        :nft_rec,
        contract: Nft::SequelModel,
        refrigeration_mode: :none,
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
      import_owner_for_all_nfts

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

    # Just easier for migrating existing code
    def nft_rec
      inputs.nft_rec
    end

    def import_owner_for_all_nfts
      # `#save` instead of `#save_changes` to update `#updated_at`
      nft_rec.set(
        owner: get_remote_owner_data(nft_rec.class_id, nft_rec.nft_id),
      ).save(changed: true)
    end

    def get_remote_owner_data(class_id, nft_id)
      # https://docs.like.co/developer/likenft/api-reference#owner
      response = http_client.get("/cosmos/nft/v1beta1/owner/#{class_id}/#{nft_id}")

      Oj.load(response.body).fetch("owner")
    end

    memo_wise def http_client
      Faraday.new(ENV![:LIKECOIN_NODE_REST_API_BASE_URL].delete_suffix("/")) do |faraday|
        faraday.response :raise_error

        # Disable persistent to avoid `Errno::EMFILE - too many open files
        # https://honeyryderchuck.gitlab.io/httpx/wiki/Faraday-Adapter`
        faraday.adapter :httpx, persistent: false
      end
    end

  end
end
