# done

* rails new
* bundle into `./.gems`
* bundle add ruby_llm
* evaluated ruby_llm gem (determined it doesn't support OpenRouter)
* decided to implement custom OpenRouter wrapper

* set up an openrouter key
  * create credentials configuration
  * implement basic OpenRouter client wrapper

* implement telegram bot integration
  * set up bot through BotFather
  * add telegram-bot-ruby gem
  * implement basic message handling
  * integrate with OpenRouter client

* standardize TelegramBotService entry points
  * unified logging configuration
  * consistent initialization across rake, bin, and foreman
  * single entry point through TelegramBotService.start

* use a code block in telegram to print debug

* improve test coverage and reliability
  * set up VCR for OpenRouter API tests
  * fix Conversation model tests
  * add comprehensive test coverage for message history
  * configure proper test environment

# next

* send a startup message to the main channel on every start
  * list open router model and other useful information
  * implement proper error handling for startup message

# soon

* implement conversation history tracking
  * add conversation pruning for long histories
  * implement conversation context management
  * add conversation persistence tests

* add error handling and logging
  * implement structured logging
  * add error monitoring
  * improve error recovery strategies

* implement user management
  * user authentication
  * user preferences
  * rate limiting per user

* add rate limiting and usage tracking
  * implement token counting
  * add usage quotas
  * track costs per user/conversation