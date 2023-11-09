# frozen_string_literal: true

module Nfts::GetRemoteNfts::GetNftsForAllNftClasses
  class Job < ApplicationJob
    def perform(...)
      Operation.call(...)
    end
  end
end
