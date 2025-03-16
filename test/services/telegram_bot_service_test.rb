require "test_helper"

class TelegramBotServiceTest < ActiveSupport::TestCase
  def setup
    @service = TelegramBotService.new(Rails.application.credentials.telegram_bot_token)
    @test_chat_id = Rails.application.credentials.telegram_test_chat_id.to_i
  end

  test "should initialize with token" do
    assert_not_nil @service
  end

  test "should handle direct message" do
    # Create a test message
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
      text: "Hello bot"
    )

    # Send the message through the service
    response = @service.send(:handle_message,
      Telegram::Bot::Client.new(@service.instance_variable_get(:@token)),
      message
    )

    # Verify that a conversation was created
    conversation = Conversation.last
    assert_not_nil conversation
    assert_equal @test_chat_id.to_s, conversation.chat_id
    assert_equal "Hello bot", conversation.user_message
    assert_not_nil conversation.assistant_message
  end

  test "should handle chat member updates" do
    update = Telegram::Bot::Types::ChatMemberUpdated.new(
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
      old_chat_member: Telegram::Bot::Types::ChatMember.new(
        user: Telegram::Bot::Types::User.new(
          id: @service.instance_variable_get(:@bot_info)&.id || 456,
          first_name: "Bot",
          username: "test_bot",
          is_bot: true
        ),
        status: "left"
      ),
      new_chat_member: Telegram::Bot::Types::ChatMember.new(
        user: Telegram::Bot::Types::User.new(
          id: @service.instance_variable_get(:@bot_info)&.id || 456,
          first_name: "Bot",
          username: "test_bot",
          is_bot: true
        ),
        status: "member"
      )
    )

    # Handle the update
    response = @service.send(:handle_chat_member_updated,
      Telegram::Bot::Client.new(@service.instance_variable_get(:@token)),
      update
    )

    # No assertions needed as this is just testing that no errors occur
    assert true
  end

  test "should handle errors gracefully" do
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
      text: nil # This should trigger an error condition
    )

    # This should not raise an error
    assert_nothing_raised do
      @service.send(:handle_message,
        Telegram::Bot::Client.new(@service.instance_variable_get(:@token)),
        message
      )
    end
  end

  test "should handle !debug command with bot mention" do
    # Create a test message with !debug command
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

    # Mock the bot client and its API
    bot_client = Telegram::Bot::Client.new(@service.instance_variable_get(:@token))
    @service.instance_variable_set(:@bot_info, OpenStruct.new(username: "test_bot", id: 456))

    # Expect debug info to be sent without calling OpenRouter
    debug_response_received = false
    bot_client.api.define_singleton_method(:send_message) do |params|
      if params[:text].start_with?("Debug Information:")
        debug_response_received = true
      end
    end

    # Process the message
    @service.send(:handle_message, bot_client, message)

    # Verify that debug info was sent and no conversation was created
    assert debug_response_received, "Debug information should have been sent"
    assert_equal 0, Conversation.where(chat_id: @test_chat_id.to_s).count, "No conversation should be created for !debug command"
  end
end
