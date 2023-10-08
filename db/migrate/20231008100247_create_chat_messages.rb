class CreateChatMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: true

      # OpenAI functions related
      t.string :name, null: true
      t.json :function_call, null: true

      t.timestamps
    end
  end
end
