# frozen_string_literal: true

module Nfts::GetRemoteNfts::GetNftsForOneClassId::GetFromRestApiNode
  class Job < ApplicationJob
    def perform(...)
      Operation.call(...)
    end
  end
end
