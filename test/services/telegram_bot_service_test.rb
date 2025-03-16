require "test_helper"
require "ostruct"
require "minitest/mock"

class TelegramBotServiceTest < ActiveSupport::TestCase
  class MockTelegramClient
    attr_reader :api

    def initialize(token)
      @token = token
      @api = MockTelegramAPI.new
    end

    def self.run(token)
      client = new(token)
      yield client if block_given?
      client
    end

    def listen
      # Simulate no messages in test environment
    end
  end

  class MockTelegramAPI
    attr_reader :sent_messages

    def initialize
      @sent_messages = []
    end

    def send_message(params)
      @sent_messages << params
    end

    def get_me
      OpenStruct.new(id: 123, username: "test_bot")
    end
  end

  class MockOpenRouterService
    def initialize
      @responses = []
    end

    def add_response(response)
      @responses << response
    end

    def chat_completion(messages)
      @responses.shift || {
        "choices" => [
          {
            "message" => {
              "content" => "Mock response"
            }
          }
        ]
      }
    end
  end

  def setup
    # Clean the database before each test
    Conversation.delete_all

    @logger = Logger.new(nil) # Null logger for tests
    @mock_open_router = MockOpenRouterService.new
    @mock_telegram_client = MockTelegramClient

    TelegramBotService.configure do |config|
      config.token = "test_token"
      config.logger = @logger
      config.open_router_service_class = MockOpenRouterService
      config.telegram_bot_client_class = @mock_telegram_client
    end

    @service = TelegramBotService.new
    @test_chat_id = 12345
  end

  test "should initialize with token" do
    assert_not_nil @service
  end

  test "should handle direct message" do
    service = TelegramBotService.new(nil, {
      open_router_service: @mock_open_router
    })

    # Create a test message with entities
    message = Telegram::Bot::Types::Message.new(
      message_id: 1,
      date: Time.current.to_i,
      chat: Telegram::Bot::Types::Chat.new(
        id: @test_chat_id,
        type: "private"
      ),
      from: Telegram::Bot::Types::User.new(
        id: 123,
        first_name: "Test",
        username: "test_user",
        is_bot: false
      ),
      text: "Hello @test_bot",
      entities: [
        Telegram::Bot::Types::MessageEntity.new(
          type: "mention",
          offset: 6,
          length: 9
        )
      ]
    )

    # Add a custom response for this test
    @mock_open_router.add_response({
      "choices" => [
        {
          "message" => {
            "content" => "Hello! How can I help you today?"
          }
        }
      ]
    })

    # Set up bot info before processing message
    bot_client = MockTelegramClient.new("test_token")
    service.instance_variable_set(:@bot_info, OpenStruct.new(username: "test_bot", id: 456))

    # Process the message without mocking recent_history
    service.send(:handle_message, bot_client, message)

    # Verify that a conversation was created
    conversation = Conversation.last
    assert_not_nil conversation
    assert_equal @test_chat_id, conversation.chat_id.to_i  # Convert string to integer for comparison
    assert_equal "Hello @test_bot", conversation.user_message
    assert_equal "Hello! How can I help you today?", conversation.assistant_message

    # Verify the bot sent a response
    assert_equal 1, bot_client.api.sent_messages.length
    sent_message = bot_client.api.sent_messages.first
    assert_equal @test_chat_id, sent_message[:chat_id]
    assert_equal "Hello! How can I help you today?", sent_message[:text]
    assert_equal 1, sent_message[:reply_to_message_id]
  end

  test "should handle chat member updates" do
    service = TelegramBotService.new(nil, {
      open_router_service: @mock_open_router
    })

    # Create a simpler chat member update
    update = OpenStruct.new(
      chat: Telegram::Bot::Types::Chat.new(
        id: @test_chat_id,
        type: "group",
        title: "Test Group"
      ),
      from: Telegram::Bot::Types::User.new(
        id: 123,
        first_name: "Test",
        username: "test_user",
        is_bot: false
      ),
      date: Time.current.to_i,
      old_chat_member: OpenStruct.new(
        user: Telegram::Bot::Types::User.new(
          id: 123,
          first_name: "Bot",
          username: "test_bot",
          is_bot: true
        ),
        status: "left"
      ),
      new_chat_member: OpenStruct.new(
        user: Telegram::Bot::Types::User.new(
          id: 123,
          first_name: "Bot",
          username: "test_bot",
          is_bot: true
        ),
        status: "member"
      )
    )

    bot_client = MockTelegramClient.new("test_token")
    service.send(:handle_chat_member_updated, bot_client, update)

    # Verify welcome message was sent
    assert_equal 1, bot_client.api.sent_messages.length
    sent_message = bot_client.api.sent_messages.first
    assert_equal @test_chat_id, sent_message[:chat_id]
    assert_equal "Hello! I'm an AI assistant. Feel free to ask me any questions!", sent_message[:text]
  end

  test "should handle errors gracefully" do
    service = TelegramBotService.new(nil, {
      open_router_service: @mock_open_router
    })

    message = Telegram::Bot::Types::Message.new(
      message_id: 1,
      date: Time.current.to_i,
      chat: Telegram::Bot::Types::Chat.new(
        id: @test_chat_id,
        type: "private"
      ),
      from: Telegram::Bot::Types::User.new(
        id: 123,
        first_name: "Test",
        username: "test_user",
        is_bot: false
      ),
      text: "" # Empty string instead of nil
    )

    bot_client = MockTelegramClient.new("test_token")

    # This should not raise an error
    assert_nothing_raised do
      service.send(:handle_message, bot_client, message)
    end
  end

  test "should handle !debug command with bot mention" do
    service = TelegramBotService.new(nil, {
      open_router_service: @mock_open_router
    })

    message = Telegram::Bot::Types::Message.new(
      message_id: 1,
      date: Time.current.to_i,
      chat: Telegram::Bot::Types::Chat.new(
        id: @test_chat_id,
        type: "private"
      ),
      from: Telegram::Bot::Types::User.new(
        id: 123,
        first_name: "Test",
        username: "test_user",
        is_bot: false
      ),
      text: "!debug @test_bot"
    )

    bot_client = MockTelegramClient.new("test_token")
    service.instance_variable_set(:@bot_info, OpenStruct.new(username: "test_bot", id: 456))

    # Process the message
    service.send(:handle_message, bot_client, message)

    # Verify that debug info was sent and no conversation was created
    assert_equal 1, bot_client.api.sent_messages.length
    sent_message = bot_client.api.sent_messages.first
    assert_equal @test_chat_id, sent_message[:chat_id]
    assert sent_message[:text].start_with?("Debug Information:")
    assert_equal 0, Conversation.where(chat_id: @test_chat_id.to_s).count
  end

  test "should allow custom configuration" do
    custom_logger = Logger.new(nil)
    custom_token = "custom_token"

    service = TelegramBotService.new(custom_token, {
      logger: custom_logger,
      open_router_service: @mock_open_router
    })

    assert_equal custom_token, service.instance_variable_get(:@token)
    assert_equal custom_logger, service.instance_variable_get(:@logger)
  end

  test "should use configuration defaults" do
    service = TelegramBotService.new

    assert_equal TelegramBotService.configuration.token, service.instance_variable_get(:@token)
    assert_equal TelegramBotService.configuration.logger, service.instance_variable_get(:@logger)
  end
end
