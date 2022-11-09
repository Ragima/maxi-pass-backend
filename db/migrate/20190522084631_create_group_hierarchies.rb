class CreateGroupHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :group_hierarchies, id: false do |t|
      t.uuid :ancestor_id, null: false
      t.uuid :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :group_hierarchies, %i[ancestor_id descendant_id generations],
              unique: true,
              name: 'group_anc_desc_idx'

    add_index :group_hierarchies, :descendant_id,
              name: 'group_desc_idx'
  end
end
