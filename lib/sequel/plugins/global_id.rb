# frozen_string_literal: true

require "globalid"

# https://github.com/TalentBox/sequel-rails/issues/111#issuecomment-1786678753
module Sequel
  module Plugins
    module GlobalId

      # Add Global ID support for Sequel::Models
      # Code comes @halostatue from https://github.com/TalentBox/sequel-rails/issues/111
      def self.apply(base, *)
        base.send(:include, ::GlobalID::Identification)
        GlobalID::Locator::BaseLocator.prepend SequelBaseLocator
      end

      module SequelBaseLocator
        def locate(gid, options = {})
          if defined?(::Sequel::Model) && gid.model_class < Sequel::Model
            gid.model_class.with_pk!(gid.model_id)
          else
            super
          end
        end

        private

        def find_records(model_class, ids, options)
          if defined?(::Sequel::Model) && model_class < Sequel::Model
            model_class.where(model_class.primary_key => ids).tap do |result|
              if !options[:ignore_missing] && result.count < ids.size
                fail Sequel::NoMatchingRow
              end
            end.all
          else
            super
          end
        end
      end

    end
  end
end
