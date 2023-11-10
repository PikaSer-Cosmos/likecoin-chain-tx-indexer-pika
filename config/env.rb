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
end
