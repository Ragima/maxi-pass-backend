# frozen_string_literal: true

class GroupInformationPdf < Prawn::Document
  def initialize(groups)
    super(top_margin: 70)
    @groups = groups
    font(Rails.root.join("public/fonts/OpenSans-Regular.ttf")) do
      table groups_table, header: true
    end
  end

  def groups_table
    table = []
    @groups.each do |group|
      initial_line = []
      parent_groups_names = group.ancestors.where(id: @groups.map(&:id)).pluck(:name)
      groups_string = "#{stringify_parent_groups(parent_groups_names.reverse)}#{stringify_group(group)}"
      initial_line << groups_string
      vaults = group.vaults.where(is_shared: true)
      vaults = [nil] unless vaults.size.positive?
      vaults.each do |vault|
        table << initial_line.push('', '') if vault.nil?
        next if vault.nil?
        vault_initial_line = initial_line.dup
        vault_initial_line << stringify_vault(vault)
        vault_items = vault.vault_items.where(only_for_admins: [false, nil])
        vault_items = [nil] unless vault_items.size.positive?
        vault_items.each do |item|
          line = vault_initial_line.dup
          line << stringify_vault_item(item)
          table << line
        end
      end
    end
    text group_for_report
    table_header + table
  end

  private

  def group_for_report
    "Group: #{@groups[0].name}"
  end

  def table_header
    [%w[Groups Vaults Items]]
  end

  def stringify_parent_groups(parent_groups_names_array)
    return '' if parent_groups_names_array.empty?

    "#{parent_groups_names_array.join(' > ')} > "
  end

  def stringify_group(group)
    group.try(:name).to_s
  end

  def stringify_vault(vault)
    vault.try(:title).to_s
  end

  def stringify_vault_item(item)
    item ? "#{item.try(:title)} (#{item.try(:type)})" : ''
  end
end
