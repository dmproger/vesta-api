class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.uuid :user_id, null: false, foreign_key: true
      t.integer :subject
      t.string :title
      t.string :text
      t.boolean :viewed, default: false

      t.timestamps
    end

    add_index :notifications, :user_id
  end
end
