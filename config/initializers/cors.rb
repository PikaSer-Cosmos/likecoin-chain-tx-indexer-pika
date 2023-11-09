# frozen_string_literal: true

require "rack/cors"

# CORS headers
# @see https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins("*")
    [
      "/apps/main_api/*",
    ].each do |resource_path|
      resource(
        resource_path,
        {
          headers:      :any,
          max_age:      30.days.to_i,
          # post and options are not needed yet
          methods:      [:get],
          # To allow '*' on allow origin
          credentials:  false,
        },
      )
    end
  end
end
