class CreateVillaSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :villa_schedules do |t|
      t.references :villa, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :price, null: false
      t.boolean :available, null: false, default: true

      t.timestamps
    end
    add_index :villa_schedules, [:villa_id, :date], unique: true
  end
end
