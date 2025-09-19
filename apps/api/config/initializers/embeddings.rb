
Rails.application.configure do
  config.x.embeddings.provider = ENV.fetch("EMBEDDINGS_PROVIDER", "mock") # "openai" | "mock"
  config.x.embeddings.dim      = Integer(ENV.fetch("EMBEDDINGS_DIM", "1536"))
  # OpenAI settings (used only if provider == "openai")
  config.x.embeddings.openai_api_key = ENV["OPENAI_API_KEY"]
  config.x.embeddings.openai_model   = ENV.fetch("OPENAI_EMBED_MODEL", "text-embedding-3-small")
  # Safety: cap batch size
  config.x.embeddings.max_batch      = Integer(ENV.fetch("EMBEDDINGS_MAX_BATCH", "64"))
end