class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.bigint :chat_id, null: false
      t.string :user_id
      t.string :username
      t.text :user_message
      t.text :assistant_message
      t.json :context, default: {}
      t.timestamps

      t.index :chat_id
      t.index :user_id
      t.index [ :chat_id, :created_at ]
    end
  end
end
