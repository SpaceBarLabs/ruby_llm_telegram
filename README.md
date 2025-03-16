# Ruby LLM Telegram Bot

This Rails application implements a Telegram bot powered by RubyLLM and OpenRouter for AI interactions.

## Requirements

* Ruby 3.3.0
* Rails 7.x
* PostgreSQL

## Configuration

### Setting up OpenRouter

1. Sign up for an account at [OpenRouter](https://openrouter.ai/settings/keys)
2. Get your API key from the dashboard

### Setting up Telegram Bot

1. Start a chat with [@BotFather](https://t.me/botfather) on Telegram
2. Send the `/newbot` command and follow the instructions to create a new bot
3. BotFather will provide you with a bot token - save this for the next step

### Rails Credentials

We use Rails credentials to securely store API keys. To add your OpenRouter API key and Telegram bot token:

```bash
# Open credentials file (replace 'development' with your environment)
rails credentials:edit --environment development
```

Add the following to your credentials:

```yaml
openrouter_api_key: your_api_key_here
telegram_bot_token: your_bot_token_here
```

### Testing the LLM Integration

To test if the LLM integration is working:

```bash
rails llm:test
```

This will attempt to generate a short joke using the configured LLM through OpenRouter.

## Development

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Setup the database:
   ```bash
   rails db:create db:migrate
   ```
4. Start the server:
   ```bash
   rails server
   ```

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
