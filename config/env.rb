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
end
