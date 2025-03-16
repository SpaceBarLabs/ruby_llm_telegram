require "telegram/bot"

class TelegramBotService
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor :token, :logger, :open_router_service_class, :telegram_bot_client_class

    def initialize
      @token = Rails.application.credentials.telegram_bot_token
      @logger = Rails.logger
      @open_router_service_class = OpenRouterService
      @telegram_bot_client_class = Telegram::Bot::Client
    end
  end

  def initialize(token = nil, options = {})
    @token = token || self.class.configuration.token
    @logger = options[:logger] || self.class.configuration.logger
    @open_router = options[:open_router_service] ||
                  self.class.configuration.open_router_service_class.new
    @telegram_client_class = options[:telegram_client_class] ||
                           self.class.configuration.telegram_bot_client_class
  end

  def start
    @logger.info("Starting Telegram bot...")
    @telegram_client_class.run(@token) do |bot|
      @logger.info("Bot connected successfully. Listening for messages...")
      @bot_info = bot.api.get_me
      @logger.info("Bot username: @#{@bot_info.username}")

      bot.listen do |message|
        case message
        when Telegram::Bot::Types::Message
          handle_message(bot, message)
        when Telegram::Bot::Types::ChatMemberUpdated
          handle_chat_member_updated(bot, message)
        else
          @logger.info("Received unsupported message type: #{message.class}")
        end
      end
    end
  rescue StandardError => e
    @logger.error("Fatal error in Telegram bot: #{e.message}")
    @logger.error(e.backtrace.join("\n"))
    raise
  end

  private

  def handle_message(bot, message)
    return unless message.text

    @logger.debug "=== DEBUG: Received message from chat_id: #{message.chat.id} ==="
    @logger.debug "=== DEBUG: Message from user: #{message.from.username || message.from.first_name} (ID: #{message.from.id}) ==="

    # Handle !debug command first
    if message.text.include?("!debug")
      handle_debug_command(bot, message)
      return
    end

    # Only proceed if the message is directed at the bot
    return unless should_process_message?(message)

    process_chat_message(bot, message)
  rescue StandardError => e
    handle_error(bot, message, e)
  end

  def handle_debug_command(bot, message)
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
  end

  def should_process_message?(message)
    is_reply_to_bot = message.reply_to_message&.from&.id == @bot_info.id
    mentions_bot = message.text.include?("@#{@bot_info.username}")
    has_bot_mention = message.entities&.any? { |entity|
      entity.type == "mention" && message.text[entity.offset, entity.length] == "@#{@bot_info.username}"
    }

    is_reply_to_bot || mentions_bot || has_bot_mention
  end

  def process_chat_message(bot, message)
    @logger.info("Received message from user #{message.from.id} (#{message.from.username}): #{message.text}")

    # Store the original message without stripping the bot mention
    user_message = message.text
    conversation_history = Conversation.recent_history(message.chat.id)
    messages = build_messages_array(conversation_history, user_message)

    @logger.info("Sending request to OpenRouter with conversation history...")
    chat_response = @open_router.chat_completion(messages)

    if chat_response && chat_response["choices"]
      handle_successful_response(bot, message, chat_response, user_message)
    else
      handle_invalid_response(bot, message, chat_response)
    end
  end

  def build_messages_array(conversation_history, user_message)
    messages = [
      { role: "system", content: "You are a helpful assistant." }
    ]
    messages.concat(conversation_history) if conversation_history.any?
    messages << { role: "user", content: user_message }
    messages
  end

  def handle_successful_response(bot, message, chat_response, user_message)
    response_text = chat_response["choices"][0]["message"]["content"]
    @logger.info("Received response from OpenRouter, sending reply...")
    @logger.debug("OpenRouter response: #{chat_response}")

    store_conversation(message, user_message, response_text)

    bot.api.send_message(
      chat_id: message.chat.id,
      text: response_text,
      reply_to_message_id: message.message_id
    )
    @logger.info("Reply sent successfully")
  end

  def handle_invalid_response(bot, message, chat_response)
    @logger.warn("OpenRouter returned invalid response: #{chat_response.inspect}")
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "I'm sorry, I couldn't process that request.",
      reply_to_message_id: message.message_id
    )
  end

  def store_conversation(message, user_message, response_text)
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
  end

  def handle_error(bot, message, error)
    @logger.error("Error processing message: #{error.message}")
    @logger.error("Backtrace:\n#{error.backtrace.join("\n")}")
    @logger.error("Original message: #{message.inspect}")

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "An error occurred while processing your message.",
      reply_to_message_id: message.message_id
    )
  end

  def handle_chat_member_updated(bot, update)
    @logger.info("Chat member update received: #{update.inspect}")

    if update.new_chat_member&.user&.id == bot.api.get_me.id
      # Bot was added to a group
      if update.new_chat_member.status == "member" || update.new_chat_member.status == "administrator"
        @logger.info("Bot was added to group: #{update.chat.title}")
        bot.api.send_message(
          chat_id: update.chat.id,
          text: "Hello! I'm an AI assistant. Feel free to ask me any questions!"
        )
      end
    end
  rescue StandardError => e
    @logger.error("Error handling chat member update: #{e.message}")
    @logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
  end
end
