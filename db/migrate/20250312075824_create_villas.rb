class CreateVillas < ActiveRecord::Migration[7.1]
  def change
    create_table :villas do |t|
      t.string :name
      t.string :address

      t.timestamps
    end
  end
end
