# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 3.4.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"
# A performance dashboard for Postgres
gem "pghero", ">= 3.3.4"
# PgHero can suggest indexes to add.
gem "pg_query", ">= 2"
# Add comment to queries
# https://ankane.org/the-origin-of-sql-queries
gem "marginalia", ">= 1.5.0"
# Simpler ORM
gem "sequel", ">= 5.73.0"
# Better rails integration for sequel
gem "sequel-rails", ">= 1.2.1"
# Provide `#in_batches`
gem "sequel-batches", ">= 2.0.2"
# sequel-annotate annotates Sequel models with schema information
gem "sequel-annotate", ">= 1.7.0", group: :development

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 6.6.0", "< 7", require: false, git: "https://github.com/toregeschliman/puma.git", branch: "mold-worker-dogfood-final"
# Rack::Timeout enhancements for Rails
gem "slowpoke"

# CORS
gem "rack-cors"

# Opt-in type checking
gem "contracts", ">= 0.17.0"
# Memorize the returned value of methods
# Good for method with expensive calculation
#
# https://github.com/panorama-ed/memo_wise
# Faster than `memoist`
gem "memo_wise", ">= 1.7.0"
# Library for creating contracted immutable value objects
gem "contracted_value", ">= 0.1.3"

# Verify correctness of environment configuration at startup time.
gem "env_bang-rails", ">= 1.0.0"
# Shim to load environment variables from .env into ENV in development.
gem "dotenv-rails", groups: [:development, :test]

# Popular wrapper for many HTTP clients
gem "faraday", ">= 2.0.1"
gem "httpx", ">= 1.0.2"

# Dry family
# https://dry-rb.org
gem "dry-struct"
gem "dry-types"
gem "dry-schema"
gem "dry-validation"

### JSON builder
# 1.3.0 for OJ related fixes
gem "turbostreamer", ">= 1.3.0"
# fastest JSON parser
gem "oj",">= 3.14.3"

# Clockwork - a clock process to replace cron
gem "clockwork"

# BG Jobs
gem "good_job", "~> 3.29"

### Assets
gem 'sprockets-rails', '>= 3.4.2', require: 'sprockets/railtie'
gem 'sprockets', '~> 4.2'

# https://github.com/azuchi/bech32rb
gem "bech32"

# https://github.com/grosser/parallel
# Run any code in parallel Processes(> use all CPUs), Threads(> speedup blocking operations), or Ractors(> use all CPUs).
gem "parallel", ">= 1.23.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "kamal", "~> 2.7"

end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
