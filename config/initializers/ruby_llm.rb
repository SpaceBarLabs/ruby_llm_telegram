require "ruby_llm"

RubyLLM.configure do |config|
  # We'll use OpenRouter as specified in your TODO
  config.provider = :openrouter

  # The API key will be loaded from environment variables
  config.api_key = ENV["OPENROUTER_API_KEY"]

  # Default to a good model, but this can be overridden per request
  config.default_model = "anthropic/claude-3-sonnet"
end
