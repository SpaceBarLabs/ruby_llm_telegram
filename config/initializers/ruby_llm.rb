require "ruby_llm"

RubyLLM.configure do |config|
  # Configure OpenRouter using OpenAI-compatible endpoints
  config.openai_api_key = Rails.application.credentials.openrouter_api_key
  config.openai_api_base = "https://openrouter.ai/api/v1"

  # Default to a good model, but this can be overridden per request
  config.default_model = "anthropic/claude-3-sonnet-20240229"
end
