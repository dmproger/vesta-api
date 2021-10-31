class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.uuid :user_id, null: false, foreign_key: true
      t.uuid :reciver
      t.string :topic
      t.text :text
      t.boolean :viewed
      t.boolean :helpful
      t.integer :grade

      t.timestamps
    end
  end
end
