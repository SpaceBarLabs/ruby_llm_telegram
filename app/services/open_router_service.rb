require "net/http"
require "json"

class OpenRouterService
  BASE_URL = "https://openrouter.ai/api/v1"
  DEFAULT_MODEL = "mistralai/mistral-7b-instruct"

  class Error < StandardError; end
  class InvalidCredentialsError < Error; end
  class InvalidRequestError < Error; end

  def initialize(api_key = Rails.application.credentials.openrouter_api_key)
    @api_key = api_key
  end

  def chat_completion(messages, model: DEFAULT_MODEL)
    return { "error" => { "message" => "Messages cannot be nil", "code" => 401 } } if messages.nil?

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
    parsed_response = JSON.parse(response.body)

    case response.code.to_i
    when 200
      parsed_response
    when 401
      { "error" => { "message" => "Invalid credentials", "code" => 401 } }
    when 400
      { "error" => { "message" => "Invalid request", "code" => 400 } }
    else
      { "error" => { "message" => "Unknown error", "code" => response.code.to_i } }
    end
  rescue JSON::ParserError => e
    Rails.logger.error("OpenRouter API JSON Parse Error: #{e.message}")
    { "error" => { "message" => "Invalid JSON response", "code" => 500 } }
  rescue StandardError => e
    Rails.logger.error("OpenRouter API Error: #{e.message}")
    nil
  end
end
