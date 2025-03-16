class Conversation < ApplicationRecord
  validates :chat_id, presence: true
  validates :user_message, presence: true
  validates :assistant_message, presence: true

  scope :for_chat, ->(chat_id) { where(chat_id: chat_id) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :recent, ->(limit = 10) { recent_first.limit(limit) }

  def self.create_from_interaction(chat_id:, user_id:, username:, user_message:, assistant_message:, context: {})
    create!(
      chat_id: chat_id,
      user_id: user_id.to_s,
      username: username,
      user_message: user_message,
      assistant_message: assistant_message,
      context: context
    )
  end

  def self.recent_history(chat_id, limit = 5)
    for_chat(chat_id).recent(limit).map do |conv|
      [
        {
          role: "user",
          content: conv.user_message,
          name: conv.username
        },
        {
          role: "assistant",
          content: conv.assistant_message
        }
      ]
    end.reverse.flatten
  end
end
