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
   ```

## Development

The application uses Foreman to manage multiple processes (web server and Telegram bot). To start all services:
```bash
foreman start
```

This will start:
- Rails server on port 5000
- Telegram bot process

For development without Foreman, you can run services individually:

Start the Rails server:
```bash
rails server
```

Start the Telegram bot:
```bash
bundle exec bin/telegram_bot
```

### Testing

Run the test suite:
```bash
rails test
```

### Environment Variables

Create a `.env` file in the root directory with the following variables:
```
RAILS_ENV=development
DATABASE_URL=postgresql://localhost/ruby_llm_telegram_development
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is available as open source under the terms of the MIT License.