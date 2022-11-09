class AddEncryptedToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :encrypted, :boolean, default: true
  end
end
