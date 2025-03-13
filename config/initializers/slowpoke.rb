# frozen_string_literal: true

require "slowpoke"

Slowpoke.on_timeout do |env|
  next if Rails.env.local?

  exception = env["action_dispatch.exception"]
  # Official doc: For threaded servers like Puma, this means killing all threads when any one of them times out. This can have a significant impact on performance.
  # This customization code is also from official doc
  Slowpoke.kill if exception && exception.backtrace.first.include?("/active_record/")
end
