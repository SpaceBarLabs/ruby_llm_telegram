require "telegram/bot"

class TelegramBotService
  def initialize(token = Rails.application.credentials.telegram_bot_token)
    @token = token
    @open_router = OpenRouterService.new
  end

  def start
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::Message
          handle_message(bot, message)
        end
      end
    end
  end

  private

  def handle_message(bot, message)
    return unless message.text

    chat_response = @open_router.chat_completion([
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: message.text }
    ])

    if chat_response && chat_response["choices"]
      response_text = chat_response["choices"][0]["message"]["content"]
      bot.api.send_message(
        chat_id: message.chat.id,
        text: response_text
      )
    else
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "I'm sorry, I couldn't process that request."
      )
    end
  rescue StandardError => e
    Rails.logger.error("Telegram Bot Error: #{e.message}")
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "An error occurred while processing your message."
    )
  end
end
