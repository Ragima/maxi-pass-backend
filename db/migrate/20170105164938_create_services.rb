# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.string :name, null: false, unique: true
      t.string :url, null: false
      t.string :description
      t.timestamps
    end
  end

  execute <<-SQL
       UPDATE users
       SET name = first_name || ' ' || last_name
       WHERE name is null OR name='';
  SQL
end
