class AddFileNameToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :file_name, :text
  end
end
