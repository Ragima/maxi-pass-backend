class UserInformationPdf < Prawn::Document
  def initialize(user)
    super(top_margin: 70)
    @user = user
    font(Rails.root.join("public/fonts/OpenSans-Regular.ttf")) do
      table user_table, header: true
    end
  end

  def vault_without_group_table
    vault_table = []
    @user.vaults.where(is_shared: true).order(title: :asc).each do |vault|
      vault_initial_line = ['']
      vault_initial_line << stringify_vault(vault)
      vault_items = vault.vault_items.where(only_for_admins: [false, nil])
      vault_items = [nil] unless vault_items.size.positive?
      vault_items.each do |item|
        line = vault_initial_line.dup
        line << stringify_vault_item(item)
        vault_table << line
      end
    end
    vault_table
  end

  def user_table
    table = []
    @user.groups.order(name: :asc).each do |group|
      initial_line = []
      groups_string = stringify_group(group)
      initial_line << groups_string
      vaults = group.vaults.where(is_shared: true).order(title: :asc)
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

    table_header + table
    table_header + table + vault_without_group_table
  end

  private

  def user_for_report
    "User: #{@user.name}, email: #{@user.email}"
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
