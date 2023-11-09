# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

module Iscn::GetRemoteIscn::GetIscnForAllNftClasses
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
      NftClass::SequelModel.dataset.in_batches(order: :desc) do |batch|
        GoodJob::Bulk.enqueue do
          batch.each do |nft_class|
            Iscn::GetRemoteIscn::GetIscnForOneIscnId::GetFromRestApiNode::Job.perform_later(
              iscn_id_prefix: nft_class.parent_iscn_id_prefix,
              iscn_version:   nft_class.parent_iscn_version_at_mint,
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

  end
end
