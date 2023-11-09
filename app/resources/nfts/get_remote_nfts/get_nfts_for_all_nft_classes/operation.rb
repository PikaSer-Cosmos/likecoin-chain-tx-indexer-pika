# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "parallel"

module Nfts::GetRemoteNfts::GetNftsForAllNftClasses
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
        # Used for bootstrapping DB faster
        :only_classes_without_nft_data,
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
      dataset.in_batches(order: :desc) do |batch|
        GoodJob::Bulk.enqueue do
          batch.each do |nft_class|
            Nfts::GetRemoteNfts::GetNftsForOneClassId::GetFromRestApiNode::Job.perform_later(
              class_id: nft_class.class_id,
            )
          end
        end
      end

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

    def dataset
      NftClass::SequelModel.dataset.yield_self do |ds|
        if inputs.created_after
          ds = ds.only_class_created_after(inputs.created_after)
        end
        if inputs.created_before
          ds = ds.only_class_created_before(inputs.created_before)
        end
        if inputs.only_classes_without_nft_data
          ds = ds.not_linked_with_these_nfts_only(Nft::SequelModel.dataset)
        end

        ds
      end
    end

  end
end
