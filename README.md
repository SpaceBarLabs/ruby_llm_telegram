# Ruby LLM Telegram Bot

This Rails application implements a Telegram bot powered by OpenRouter for AI interactions. It provides a simple interface for users to interact with various AI models through Telegram.

## Requirements

* Ruby 3.3.0
* Rails 7.x
* PostgreSQL
* OpenRouter API key
* Telegram Bot Token
* Foreman (for process management)

## Project Status

Currently in development. Core features being implemented:
- [x] Basic Rails application setup
- [x] Dependencies configuration
- [x] OpenRouter integration
- [x] Telegram Bot implementation
- [x] Standardized bot entry points
- [x] Comprehensive test coverage
- [ ] Conversation handling
- [ ] User management

## Configuration

### Initial Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Setup the database:
   ```bash
   rails db:create db:migrate
   ```

### Setting up OpenRouter

1. Sign up for an account at [OpenRouter](https://openrouter.ai/settings/keys)
2. Get your API key from the dashboard
3. Add the key to your Rails credentials:
   ```bash
   # Open credentials file (replace 'development' with your environment)
   rails credentials:edit --environment development
   ```
   Add to your credentials:
   ```yaml
   openrouter_api_key: your_api_key_here
   app_url: "https://your-app-url.com"  # or http://localhost:3000 for development
   ```

### Setting up Telegram Bot

1. Start a chat with [@BotFather](https://t.me/botfather) on Telegram
2. Send the `/newbot` command and follow the instructions to create a new bot
3. Save the bot token provided by BotFather
4. Add the token to your Rails credentials:
   ```yaml
   telegram_bot_token: your_bot_token_here
   telegram_main_channel_id: your_channel_id_here  # Optional: for startup messages
   ```

## Development

The application uses Foreman to manage multiple processes (web server and Telegram bot). To start all services:
```bash
foreman start
```

This will start:
- Rails server on port 5000
- Telegram bot process

### Starting the Bot

There are three standardized ways to start the bot, all using the same underlying initialization:

1. Using Foreman (recommended for development):
   ```bash
   foreman start
   ```

2. Using Rake task (recommended for production):
   ```bash
   bundle exec rake telegram:start
   ```

3. Using the binary directly:
   ```bash
   bundle exec bin/telegram_bot
   ```

All methods provide identical functionality and logging configuration. Choose the one that best fits your deployment environment.

### Environment Variables

Create a `.env` file in the root directory with the following variables:
```
RAILS_ENV=development
DATABASE_URL=postgresql://localhost/ruby_llm_telegram_development
```

### Testing

The project uses Minitest for testing and VCR for recording HTTP interactions. This ensures tests are reliable and don't make actual API calls during test runs.

Run the test suite:
```bash
rails test
```

#### VCR Cassettes

The project uses VCR to record and replay HTTP interactions in tests. Cassettes are stored in `test/vcr_cassettes/`. When debugging API-related tests, you might want to delete the relevant cassette to record new interactions:

```bash
# Remove specific cassette
rm test/vcr_cassettes/openrouter/specific_cassette.yml

# Remove all OpenRouter cassettes
rm test/vcr_cassettes/openrouter/*
```

#### Test Environment Credentials

For testing OpenRouter API interactions, you'll need to set up test credentials:

```bash
rails credentials:edit --environment test
```

Add the following to your test credentials:
```yaml
openrouter_api_key: your_test_api_key_here
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is available as open source under the terms of the MIT License.