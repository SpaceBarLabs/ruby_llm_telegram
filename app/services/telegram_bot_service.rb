require "telegram/bot"

class TelegramBotService
  def initialize(token = Rails.application.credentials.telegram_bot_token)
    @token = token
    @open_router = OpenRouterService.new
    Rails.logger.info("TelegramBotService initialized with token: #{token[0..4]}...")
  end

  def start
    Rails.logger.info("Starting Telegram bot...")
    Telegram::Bot::Client.run(@token) do |bot|
      Rails.logger.info("Bot connected successfully. Listening for messages...")
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::Message
          handle_message(bot, message)
        when Telegram::Bot::Types::ChatMemberUpdated
          handle_chat_member_updated(bot, message)
        else
          Rails.logger.info("Received unsupported message type: #{message.class}")
        end
      end
    end
  rescue StandardError => e
    Rails.logger.error("Fatal error in Telegram bot: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end

  private

  def handle_message(bot, message)
    return unless message.text

    Rails.logger.info("Received message from user #{message.from.id} (#{message.from.username}): #{message.text}")

    Rails.logger.info("Sending request to OpenRouter...")
    chat_response = @open_router.chat_completion([
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: message.text }
    ])

    if chat_response && chat_response["choices"]
      response_text = chat_response["choices"][0]["message"]["content"]
      Rails.logger.info("Received response from OpenRouter, sending reply...")
      Rails.logger.debug("OpenRouter response: #{chat_response}")

      bot.api.send_message(
        chat_id: message.chat.id,
        text: response_text
      )
      Rails.logger.info("Reply sent successfully")
    else
      Rails.logger.warn("OpenRouter returned invalid response: #{chat_response.inspect}")
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "I'm sorry, I couldn't process that request."
      )
    end
  rescue StandardError => e
    Rails.logger.error("Error processing message: #{e.message}")
    Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
    Rails.logger.error("Original message: #{message.inspect}")

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "An error occurred while processing your message."
    )
  end

  def handle_chat_member_updated(bot, update)
    Rails.logger.info("Chat member update received: #{update.inspect}")

    if update.new_chat_member&.user&.id == bot.api.get_me.id
      # Bot was added to a group
      if update.new_chat_member.status == "member" || update.new_chat_member.status == "administrator"
        Rails.logger.info("Bot was added to group: #{update.chat.title}")
        bot.api.send_message(
          chat_id: update.chat.id,
          text: "Hello! I'm an AI assistant. Feel free to ask me any questions!"
        )
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error handling chat member update: #{e.message}")
    Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
  end
end
