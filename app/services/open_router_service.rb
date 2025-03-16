require "net/http"
require "json"

class OpenRouterService
  BASE_URL = "https://openrouter.ai/api/v1"

  def initialize(api_key = Rails.application.credentials.openrouter_api_key)
    @api_key = api_key
  end

  def chat_completion(messages, model: "mistralai/mistral-7b-instruct")
    uri = URI("#{BASE_URL}/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request["HTTP-Referer"] = Rails.application.credentials.app_url || "http://localhost:3000"

    request.body = {
      model: model,
      messages: messages
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("OpenRouter API Error: #{e.message}")
    nil
  end
end
