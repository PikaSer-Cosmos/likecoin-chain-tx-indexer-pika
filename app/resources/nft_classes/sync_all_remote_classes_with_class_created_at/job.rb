# frozen_string_literal: true

module NftClasses::SyncAllRemoteClassesWithClassCreatedAt
  class Job < ApplicationJob
    def perform(...)
      # Ensures that all created classes have `#class_created_at` filled
      NftClasses::SyncAllRemoteClasses::GetFromRestApiNode::Operation.call
      NftClasses::GetRemoteClassCreatedAt::GetFromLikecoinIndexer::GetForAllClasses::Operation.call
    end
  end
end
