ENV!.config do
  use(
    :LIKECOIN_NODE_REST_API_BASE_URL,
    <<~DESC.strip,
      Can use value from https://cosmos.directory/likecoin/nodes
      You can use your own API endpoint (even a local one)
    DESC
    # Default to PikaSer API to avoid rate limit
    default: "https://rest-likecoin-mainnet.pikaser.net",
  )

  use(
    :PGHERO_DASHBOARD_ENABLED,
    <<~DESC.strip,
      Enable https://github.com/ankane/pghero dashboard
    DESC
    class: :boolean,
    default: false,
  )

  use(
    :GOOD_JOB_DASHBOARD_ENABLED,
    <<~DESC.strip,
      Enable https://github.com/bensheldon/good_job dashboard
    DESC
    class: :boolean,
    default: false,
  )

  # region DB related

  use(
    :DATABASE_POOL_SIZE,
    "Database Connection Pool Size for AR",
    class: Integer,
    # 0 = auto calculated, see config/initializers/active_record_database_connection_config.rb
    default: 0,
  )
  use(
    :DATABASE_REAPING_FREQUENCY,
    "Database Connection Pool Reaping Frequency for AR (in seconds)",
    class: Integer,
    default: 10,
  )
  use(
    :DATABASE_USE_PREPARED_STATEMENTS,
    "Enable Database Connection to use Prepared Statements",
    class: :boolean,
    default: true,
  )
  use(
    :DATABASE_DEFAULT_STATEMENT_TIMEOUT,
    # DB Query execution timeout
    # See PSQL config for details
    # https://postgresqlco.nf/doc/en/param/statement_timeout/
    #
    # Value can be updated per job/session
    # e.g.https://www.citusdata.com/blog/2017/04/28/postgres-tips-for-rails/
    "Default statement (DB query) timeout",
    class: ::String,
    default: "0",
  )

  # endregion DB related
end
