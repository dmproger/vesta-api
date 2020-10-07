class CreateGcEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :gc_events, id: :uuid do |t|
      t.string :gc_event_id

      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
