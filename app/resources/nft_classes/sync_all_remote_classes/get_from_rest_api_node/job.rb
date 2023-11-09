# frozen_string_literal: true

module NftClasses::SyncAllRemoteClasses::GetFromRestApiNode
  class Job < ApplicationJob
    def perform(...)
      Operation.call(...)
    end
  end
end
