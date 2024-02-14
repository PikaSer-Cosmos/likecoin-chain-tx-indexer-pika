# frozen_string_literal: true

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.connection_pool.disconnect!
  # Could be nil in 4.1
  db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary")
  # Frozen hash returned by `#configuration_hash`, must call `#dup`
  db_config_hash = db_config.configuration_hash.dup
  database_pool_size = begin
    env_value = ENV![:DATABASE_POOL_SIZE]
    # BG worker should have different DB pool value
    if ENV["GOOD_JOB_MAX_THREADS"]
      env_value = 1 + 2 + ENV["GOOD_JOB_MAX_THREADS"].to_i
    elsif env_value.zero?
      # Probably puma/web
      # https://judoscale.com/guides/active-record-connection-pool
      web_concurrency = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
      rails_max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 3))
      # Plus 6 as buffer, not tested
      env_value = (web_concurrency * rails_max_threads) + 6
    end
    env_value
  end
  db_config_hash.merge!(
    # seconds
    reaping_frequency:    ENV![:DATABASE_REAPING_FREQUENCY],
    pool:                 database_pool_size,
    prepared_statements:  ENV![:DATABASE_USE_PREPARED_STATEMENTS],
    # Ref: https://devcenter.heroku.com/articles/concurrency-and-database-connections
    variables:            (db_config_hash["variables"] || {}).merge(
      # Must be strings even keys
      "statement_timeout" => ENV![:DATABASE_DEFAULT_STATEMENT_TIMEOUT],
    ),
  )
  ActiveRecord::Base.establish_connection(
    ActiveRecord::DatabaseConfigurations::HashConfig.new(
      db_config.env_name,
      db_config.name,
      db_config_hash,
    ),
  )
end
