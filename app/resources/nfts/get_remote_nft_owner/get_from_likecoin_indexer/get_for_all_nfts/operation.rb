# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "httpx/adapters/faraday"

module Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForAllNfts
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      attribute(
        :created_after,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        :created_before,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        :updated_after,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        :updated_before,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        :class_created_after,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        :class_created_before,
        contract: Maybe[ActiveSupport::TimeWithZone],
        refrigeration_mode: :none,
        default_value: nil,
      )

      attribute(
        # Used for bootstrapping DB faster
        :only_nfts_without_owner,
        contract: Enum[true, false],
        default_value: false,
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

    def import_owner_for_all_nfts
      dataset.in_batches(order: :desc) do |batch|
        GoodJob::Bulk.enqueue do
          batch.each do |nft_rec|
            Nfts::GetRemoteNftOwner::GetFromLikecoinIndexer::GetForOneNft::Job.perform_later(nft_rec: nft_rec)
          end
        end
      end
    end

    def dataset
      Nft::SequelModel.dataset.yield_self do |ds|
        if inputs.created_after
          ds = ds.only_created_after(inputs.created_after)
        end
        if inputs.created_before
          ds = ds.only_created_before(inputs.created_before)
        end

        if inputs.updated_after
          ds = ds.only_updated_after(inputs.updated_after)
        end
        if inputs.updated_before
          ds = ds.only_updated_before(inputs.updated_before)
        end

        if inputs.class_created_after
          ds = ds.only_class_created_after(inputs.class_created_after)
        end
        if inputs.class_created_before
          ds = ds.only_class_created_before(inputs.class_created_before)
        end

        if inputs.only_nfts_without_owner
          ds = ds.without_owner_only
        end

        ds
      end
    end

  end
end
