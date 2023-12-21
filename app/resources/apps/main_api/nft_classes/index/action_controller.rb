# frozen_string_literal: true

require "contracts"
require "memo_wise"

module Apps::MainApi::NftClasses::Index
  class ActionController < ApplicationController
    prepend ::MemoWise
    include ::Contracts::Core
    include ::Contracts::Builtin

    prepend_view_path(
      File.expand_path(
        "./templates",
        __dir__,
      ),
    )

    def call
      if params_validation_result.failure?
        render(json: {errors: params_validation_result.errors.to_h}, status: 422)
        return
      end

      render(
        "/nft_classes",
        locals: {
          nft_classes: nft_classes,
        },
      )
    end

    private

    def nft_classes
      NftClass::SequelModel.eager(:iscn).order(Sequel.desc(:class_created_at)).yield_self do |rel|
        rel = rel.where(class_created_at: (..parsed_params.created_before_in_time)) if parsed_params.created_before
        rel = rel.where(class_created_at: (parsed_params.created_after_in_time..)) if parsed_params.created_after

        if parsed_params.iscn_owner
          rel = rel.linked_with_thses_iscn_only(Iscn::SequelModel.with_owner_only(parsed_params.iscn_owner))
        end

        if parsed_params.nft_owner
          rel = rel.linked_with_these_nfts_only(Nft::SequelModel.with_owner_only(parsed_params.nft_owner))
        end

        if parsed_params.nft_type_category
          case parsed_params.nft_type_category
          when NftTypeCategory::WritingNft
            rel = rel.as_likerland_writing_nft_only
          when NftTypeCategory::NftBook
            rel = rel.as_nft_book_only
          else
            raise "Unexpected nft_type_category <#{parsed_params.nft_type_category}>"
          end
        end

        rel.limit(parsed_params.limit)
      end
    end

    memo_wise def parsed_params
      ValidParamsStruct.new(params_validation_result.to_h)
    end

    memo_wise def params_validation_result
      ValidParamsContract.new.call(params.to_unsafe_h)
    end

    module NftTypeCategory
      WritingNft = "writing_nft"
      NftBook = "nft_book"

      def self.all
        constants(false).map do |c|
          const_get(c)
        end.freeze
      end
    end

    class ValidParamsContract < Dry::Validation::Contract
      params do
        optional(:created_before).maybe(:string)
        optional(:created_after).maybe(:string)

        optional(:iscn_owner).maybe(:string)
        optional(:nft_owner).maybe(:string)

        optional(:nft_type_category).maybe(:string, included_in?: NftTypeCategory.all)

        optional(:limit).value(Dry::Schema::Types::Params::Integer, gteq?: 1, lteq?: 1000)
      end
    end
    private_constant :ValidParamsContract

    class ValidParamsStruct < ::Dry::Struct
      module Types
        include Dry.Types()
      end

      attribute? :created_before, Types::String.optional
      attribute? :created_after, Types::String.optional

      attribute? :iscn_owner, Types::String.optional
      attribute? :nft_owner, Types::String.optional

      attribute? :nft_type_category, Types::String.enum(*NftTypeCategory.all).optional

      attribute? :limit, Types::Integer.default(1000)

      def created_before_in_time
        return nil if created_before.nil?
        # Unix time in seconds
        return ::Time.zone.at(created_before.to_i) if created_before.match?(/^\d+$/)

        ::Time.zone.parse(created_before)
      end
      def created_after_in_time
        return nil if created_after.nil?
        # Unix time in seconds
        return ::Time.zone.at(created_after.to_i) if created_after.match?(/^\d+$/)

        ::Time.zone.parse(created_after)
      end
    end
    private_constant :ValidParamsStruct

  end
end
