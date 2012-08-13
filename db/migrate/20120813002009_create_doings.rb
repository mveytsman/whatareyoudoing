class CreateDoings < ActiveRecord::Migration
  def change
    create_table :doings do |t|
      t.string :phone_number
      t.text :thing
      t.timestamps
    end
  end
end
