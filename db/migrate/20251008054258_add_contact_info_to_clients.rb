class AddContactInfoToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :first_name, :string
    add_column :clients, :last_name, :string
  end
end
