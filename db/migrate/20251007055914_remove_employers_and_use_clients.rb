class RemoveEmployersAndUseClients < ActiveRecord::Migration[8.0]
  def change
    # Remove foreign keys first
    remove_foreign_key :clients, :employers if foreign_key_exists?(:clients, :employers)
    remove_foreign_key :projects, :employers if foreign_key_exists?(:projects, :employers)
    remove_foreign_key :time_entries, :employers if foreign_key_exists?(:time_entries, :employers)
    remove_foreign_key :invoices, :employers if foreign_key_exists?(:invoices, :employers)

    # Remove employer relationship from clients
    remove_reference :clients, :employer, index: true

    # Remove employer_id from invoices
    remove_column :invoices, :employer_id, :integer

    # Rename employer_id to client_id in projects
    rename_column :projects, :employer_id, :client_id

    # Rename employer_id to client_id in time_entries
    rename_column :time_entries, :employer_id, :client_id

    # Add proper foreign keys
    add_foreign_key :projects, :clients
    add_foreign_key :time_entries, :clients

    # Drop the employers table
    drop_table :employers do |t|
      t.string :name
      t.timestamps
    end
  end
end
