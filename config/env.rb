ENV!.config do
  use(
    :LIKECOIN_NODE_REST_API_BASE_URL,
    <<~DESC.strip,
      Default value from https://cosmos.directory/likecoin/nodes
      You can use your own API endpoint (even a local one)
    DESC
    default: "https://rest.cosmos.directory/likecoin",
  )
end
