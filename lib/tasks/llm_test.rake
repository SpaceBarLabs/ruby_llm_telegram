namespace :llm do
  desc "Test the OpenRouter integration"
  task test: :environment do
    puts "\n=== Starting LLM Test ==="
    puts "Testing OpenRouter integration..."

    puts "\nChecking configuration..."
    api_key = Rails.application.credentials.openrouter_api_key
    puts "API Key present?: #{!api_key.nil? && !api_key.empty?}"

    puts "\nAttempting to make API call..."
    begin
      service = OpenRouterService.new
      response = service.chat_completion(
        [ { role: "user", content: "Tell me a short joke about Ruby programming." } ],
        model: "anthropic/claude-3-sonnet-20240229"
      )

      puts "\nAPI call successful!"
      puts "\nResponse from LLM:"
      puts response.dig("choices", 0, "message", "content")
    rescue => e
      puts "\nError occurred during API call:"
      puts "Error class: #{e.class}"
      puts "Error message: #{e.message}"
      puts "Error backtrace:"
      puts e.backtrace
    end
    puts "\n=== Test Complete ==="
  end
end
