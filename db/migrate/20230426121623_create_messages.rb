class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :recipient
      t.text :message
      t.datetime :scheduled_at

      t.timestamps
    end
  end
end
