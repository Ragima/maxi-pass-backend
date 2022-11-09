# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.references :vault_item
      t.text :content
      t.attachment :file
      t.timestamps
    end
  end
end
