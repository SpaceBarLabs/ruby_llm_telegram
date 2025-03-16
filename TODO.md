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

# next

* send a startup message to the main channel on every start - list open router model and other useful information - this is implemented and failing


# soon

* implement conversation history tracking
* add error handling and logging
* implement user management
* add rate limiting and usage tracking
* chat history is going to start to get too long, we need to handle that
* can we queue log results in our tests only display on failure? - probably not needed, assertions do this