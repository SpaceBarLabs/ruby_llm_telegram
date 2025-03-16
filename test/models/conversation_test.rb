require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      chat_id: "123456",
      user_id: "789",
      username: "test_user",
      user_message: "Hello bot",
      assistant_message: "Hello human",
      context: { timestamp: Time.current.to_i }
    }
  end

  test "should create a valid conversation" do
    conversation = Conversation.new(@valid_attributes)
    assert conversation.valid?
  end

  test "should require chat_id" do
    conversation = Conversation.new(@valid_attributes.merge(chat_id: nil))
    refute conversation.valid?
    assert_includes conversation.errors[:chat_id], "can't be blank"
  end

  test "should require user_message" do
    conversation = Conversation.new(@valid_attributes.merge(user_message: nil))
    refute conversation.valid?
    assert_includes conversation.errors[:user_message], "can't be blank"
  end

  test "should require assistant_message" do
    conversation = Conversation.new(@valid_attributes.merge(assistant_message: nil))
    refute conversation.valid?
    assert_includes conversation.errors[:assistant_message], "can't be blank"
  end

  test "should create from interaction" do
    conversation = Conversation.create_from_interaction(
      chat_id: @valid_attributes[:chat_id],
      user_id: @valid_attributes[:user_id],
      username: @valid_attributes[:username],
      user_message: @valid_attributes[:user_message],
      assistant_message: @valid_attributes[:assistant_message],
      context: @valid_attributes[:context]
    )

    assert conversation.persisted?
    assert_equal @valid_attributes[:chat_id], conversation.chat_id
    assert_equal @valid_attributes[:user_message], conversation.user_message
  end

  test "should retrieve recent history in correct format" do
    # Create a few conversations
    3.times do |i|
      Conversation.create_from_interaction(
        chat_id: @valid_attributes[:chat_id],
        user_id: @valid_attributes[:user_id],
        username: @valid_attributes[:username],
        user_message: "User message #{i}",
        assistant_message: "Assistant message #{i}",
        context: { timestamp: Time.current.to_i - i }
      )
    end

    history = Conversation.recent_history(@valid_attributes[:chat_id], 2)

    assert_equal 4, history.length # 2 conversations * 2 messages each
    assert_equal "user", history.first[:role]
    assert_equal "assistant", history.second[:role]
    assert_includes history.first[:content], "User message"
    assert_includes history.second[:content], "Assistant message"
  end

  test "should order recent history from oldest to newest" do
    timestamps = [ 3.minutes.ago, 2.minutes.ago, 1.minute.ago ]

    timestamps.each_with_index do |timestamp, i|
      Conversation.create_from_interaction(
        chat_id: @valid_attributes[:chat_id],
        user_id: @valid_attributes[:user_id],
        username: @valid_attributes[:username],
        user_message: "Message #{i}",
        assistant_message: "Response #{i}",
        context: { timestamp: timestamp.to_i }
      )
    end

    history = Conversation.recent_history(@valid_attributes[:chat_id])
    messages = history.select { |msg| msg[:role] == "user" }.map { |msg| msg[:content] }

    assert_equal "Message 0", messages.first
    assert_equal "Message 2", messages.last
  end
end
