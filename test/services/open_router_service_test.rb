require "test_helper"

class OpenRouterServiceTest < ActiveSupport::TestCase
  def setup
    @api_key = Rails.application.credentials.openrouter_api_key
    @service = OpenRouterService.new(@api_key)
  end

  test "should initialize with api key" do
    assert_not_nil @service
    assert_equal @api_key, @service.instance_variable_get(:@api_key)
  end

  test "should handle chat completion request" do
    messages = [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "What is 2+2?" }
    ]

    VCR.use_cassette("openrouter/chat_completion_basic") do
      response = @service.chat_completion(messages)

      assert_not_nil response
      assert_not_nil response["choices"]
      assert_not_empty response["choices"]
      assert_not_nil response["choices"][0]["message"]["content"]
    end
  end

  test "should handle invalid messages gracefully" do
    VCR.use_cassette("openrouter/chat_completion_invalid") do
      response = @service.chat_completion(nil)
      assert_not_nil response
      assert_not_nil response["error"]
      assert_equal 401, response["error"]["code"]
    end
  end

  test "should handle network errors gracefully" do
    VCR.turned_off do
      WebMock.allow_net_connect!
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
      WebMock.disable_net_connect!
    end
  end

  test "should use specified model" do
    messages = [ { role: "user", content: "Hello" } ]
    model = "anthropic/claude-2"

    VCR.use_cassette("openrouter/chat_completion_with_model") do
      response = @service.chat_completion(messages, model: model)

      assert_not_nil response
      assert_not_nil response["choices"]
      assert_not_empty response["choices"]
      assert_not_nil response["choices"][0]["message"]["content"]
    end
  end
end
