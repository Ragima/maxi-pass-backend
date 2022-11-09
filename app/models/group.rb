# frozen_string_literal: true

class Group < ApplicationRecord
  include PublicActivity::Common

  belongs_to :team, foreign_key: 'team_name'
  belongs_to :group, foreign_key: 'parent_group_id', optional: true

  has_many :groups, foreign_key: 'parent_group_id', dependent: :destroy
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  has_many :group_vaults, dependent: :destroy
  has_many :vaults, through: :group_vaults
  has_many :group_admin_keys, dependent: :destroy

  has_closure_tree parent_column_name: 'parent_group_id', order: 'name'

  def self.find_by_group_id(group_id)
    find_by(id: group_id)
  end

  def self.get_lead_groups(user)
    groups = []
    groups_user = GroupUser.where(user_id: user.id, role: 'lead')
    groups_user.each { |group_user| groups.push(group_user.group) }
    get_inner_lead_groups(groups).uniq
  end

  def get_inner_lead_groups(groups)
    groups_exist = []
    groups.each do |group|
      groups_exist.push(group)
      groups_exist.concat(get_inner_lead_groups(group.groups)) if group.groups.positive?
    end
    groups_exist
  end

  def remove_vaults_key_from_inner_groups(group, vault)
    group.group_vaults.find_by(group_id: group.id, vault_id: vault.id)&.destroy!
    remove_vaults_key_from_inner_groups(group.groups, vault) if group.groups
  end

  def groups_without_dependencies(user)
    children_groups = user.team.groups.where('parent_group_id IS NOT NULL')
    user.team.groups.where('parent_group_id IS NULL AND id NOT IN (?)', children_groups.pluck(:parent_group_id))
  end

  def self.generate_report(group, report_file_location)
    groups = [group, *group.descendants]

    pdf = GroupInformationPdf.new(groups)
    pdf.render_file File.join(report_file_location)
  end
end
