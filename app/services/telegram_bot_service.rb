require "telegram/bot"

class TelegramBotService
  def initialize(token = Rails.application.credentials.telegram_bot_token)
    @token = token
    @open_router = OpenRouterService.new
    Rails.logger.info("TelegramBotService initialized with token: #{token.to_s[0..4]}...#{token.to_s[-4..-1]}")
  end

  def start
    Rails.logger.info("Starting Telegram bot...")
    Telegram::Bot::Client.run(@token) do |bot|
      Rails.logger.info("Bot connected successfully. Listening for messages...")
      @bot_info = bot.api.get_me
      Rails.logger.info("Bot username: @#{@bot_info.username}")

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

    Rails.logger.debug "=== DEBUG: Received message from chat_id: #{message.chat.id} ==="
    Rails.logger.debug "=== DEBUG: Message from user: #{message.from.username || message.from.first_name} (ID: #{message.from.id}) ==="

    # Handle !debug command first
    if message.text.include?("!debug")
      debug_info = {
        chat_id: message.chat.id,
        chat_type: message.chat.type,
        user_id: message.from.id,
        username: message.from.username,
        first_name: message.from.first_name,
        bot_info: {
          username: @bot_info.username,
          id: @bot_info.id
        },
        message_id: message.message_id,
        date: Time.at(message.date).utc.iso8601
      }

      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Debug Information:\n#{JSON.pretty_generate(debug_info)}",
        reply_to_message_id: message.message_id
      )
      return
    end

    # Check if the message is a reply to the bot's message
    is_reply_to_bot = message.reply_to_message&.from&.id == @bot_info.id
    # Check if the message mentions the bot using @username
    mentions_bot = message.text.include?("@#{@bot_info.username}")
    # Check if the message contains entities that mention the bot
    has_bot_mention = message.entities&.any? { |entity|
      entity.type == "mention" && message.text[entity.offset, entity.length] == "@#{@bot_info.username}"
    }

    # Only proceed if the message is directed at the bot
    return unless is_reply_to_bot || mentions_bot || has_bot_mention

    Rails.logger.info("Received message from user #{message.from.id} (#{message.from.username}): #{message.text}")

    # Remove the bot mention from the message text if it exists
    user_message = message.text.gsub("@#{@bot_info.username}", "").strip

    # Get recent conversation history
    conversation_history = Conversation.recent_history(message.chat.id)

    # Prepare the messages array with system message and conversation history
    messages = [
      { role: "system", content: "You are a helpful assistant." }
    ]
    messages.concat(conversation_history) if conversation_history.any?
    messages << { role: "user", content: user_message }

    Rails.logger.info("Sending request to OpenRouter with conversation history...")
    chat_response = @open_router.chat_completion(messages)

    if chat_response && chat_response["choices"]
      response_text = chat_response["choices"][0]["message"]["content"]
      Rails.logger.info("Received response from OpenRouter, sending reply...")
      Rails.logger.debug("OpenRouter response: #{chat_response}")

      # Store the conversation
      Conversation.create_from_interaction(
        chat_id: message.chat.id,
        user_id: message.from.id.to_s,
        username: message.from.username || message.from.first_name,
        user_message: user_message,
        assistant_message: response_text,
        context: {
          timestamp: Time.current.to_i,
          chat_type: message.chat.type,
          message_id: message.message_id
        }
      )

      bot.api.send_message(
        chat_id: message.chat.id,
        text: response_text,
        reply_to_message_id: message.message_id
      )
      Rails.logger.info("Reply sent successfully")
    else
      Rails.logger.warn("OpenRouter returned invalid response: #{chat_response.inspect}")
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "I'm sorry, I couldn't process that request.",
        reply_to_message_id: message.message_id
      )
    end
  rescue StandardError => e
    Rails.logger.error("Error processing message: #{e.message}")
    Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
    Rails.logger.error("Original message: #{message.inspect}")

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "An error occurred while processing your message.",
      reply_to_message_id: message.message_id
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
