namespace :llm do
  desc "Test the ruby_llm integration"
  task test: :environment do
    puts "Testing ruby_llm integration..."

    response = RubyLLM.generate(
      "Tell me a short joke about Ruby programming.",
      model: "anthropic/claude-3-sonnet",
      temperature: 0.7
    )

    puts "\nResponse from LLM:"
    puts response
  end
end
