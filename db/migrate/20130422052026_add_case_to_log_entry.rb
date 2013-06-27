class AddCaseToLogEntry < ActiveRecord::Migration
  def change
    add_column :log_entries, :code, :string
  end
end
