# frozen_string_literal: true

require "contracts"
require "memo_wise"

require "contracted_value"

require "bech32"

module Cosmos::Account::Addresses::ConvertOneAddressToManyVariants
  class Operation
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    class Inputs < ::ContractedValue::Value
      include ::Contracts::Core
      include ::Contracts::Builtin

      attribute(
        # Might not be valid address
        :address,
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

      attribute(
        # Could be empty if invalid address provided
        :addresses,
        contract: ArrayOf[And[::String, Send[:present?]]],
      )

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
      Result.new(
        addresses: addresses,
      )
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

    def addresses
      hrp, data, spec = Bech32.decode(inputs.address)
      # Only need to check one of them
      return [] if hrp.nil?

      ADDRESS_PREFIXES.map do |prefix|
        Bech32.encode(prefix, data, spec)
      end
    end

    # https://docs.cosmos.network/v0.47/learn/beginner/accounts
    # LikeCoin got multiple possible prefixes
    ADDRESS_PREFIXES = %w[like cosmos].freeze
    private_constant :ADDRESS_PREFIXES


  end
end
