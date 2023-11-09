# frozen_string_literal: true

module Iscn::GetRemoteIscn::GetIscnForOneIscnId::GetFromRestApiNode
  class Job < ApplicationJob
    def perform(...)
      Operation.call(...)
    end
  end
end
