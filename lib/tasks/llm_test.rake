namespace :llm do
  desc "Test the ruby_llm integration with OpenRouter"
  task test: :environment do
    puts "\n=== Starting LLM Test ==="
    puts "Testing ruby_llm integration with OpenRouter..."

    puts "\nChecking configuration..."
    api_key = Rails.application.credentials.openrouter_api_key
    puts "API Key present?: #{!api_key.nil? && !api_key.empty?}"
    puts "API Base URL: #{RubyLLM.configuration.openai_api_base}"
    puts "Default model: #{RubyLLM.configuration.default_model}"

    puts "\nAttempting to make API call..."
    begin
      response = RubyLLM.chat.ask(
        "Tell me a short joke about Ruby programming.",
        model: "anthropic/claude-3-sonnet-20240229"
      )

      puts "\nAPI call successful!"
      puts "\nResponse from LLM:"
      puts response
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
