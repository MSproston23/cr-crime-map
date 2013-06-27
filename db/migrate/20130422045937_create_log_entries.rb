class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.string :log_id
      t.string :date
      t.string :call
      t.string :addr
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.float :lat
      t.float :lng
      t.boolean :gmaps

      t.timestamps
    end
  end
end
