require "test_helper"

class OpenRouterServiceTest < ActiveSupport::TestCase
  def setup
    @service = OpenRouterService.new(Rails.application.credentials.test.openrouter_api_key)
  end

  test "should initialize with api key" do
    assert_not_nil @service
  end

  test "should handle chat completion request" do
    messages = [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "What is 2+2?" }
    ]

    response = @service.chat_completion(messages)

    assert_not_nil response
    assert_not_nil response["choices"]
    assert_not_empty response["choices"]
    assert_not_nil response["choices"][0]["message"]["content"]
  end

  test "should handle invalid messages gracefully" do
    response = @service.chat_completion(nil)
    assert_nil response
  end

  test "should handle network errors gracefully" do
    # Temporarily change the BASE_URL to trigger a network error
    original_url = OpenRouterService::BASE_URL
    OpenRouterService.send(:remove_const, :BASE_URL)
    OpenRouterService.const_set(:BASE_URL, "https://invalid-url-that-does-not-exist.example")

    response = @service.chat_completion([ { role: "user", content: "test" } ])
    assert_nil response

  ensure
    # Restore the original BASE_URL
    OpenRouterService.send(:remove_const, :BASE_URL)
    OpenRouterService.const_set(:BASE_URL, original_url)
  end

  test "should use specified model" do
    messages = [ { role: "user", content: "Hello" } ]
    model = "anthropic/claude-2"

    response = @service.chat_completion(messages, model: model)

    assert_not_nil response
    assert_not_nil response["model"]
    assert_equal model, response["model"]
  end
end
