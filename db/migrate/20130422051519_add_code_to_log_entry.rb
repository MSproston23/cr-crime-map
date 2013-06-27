class AddCodeToLogEntry < ActiveRecord::Migration
  def change
   add_column :log_entries, :case, :string
  end
end
