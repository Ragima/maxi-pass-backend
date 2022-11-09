# frozen_string_literal: true

class Vault < ApplicationRecord
  include PublicActivity::Common

  belongs_to :team, foreign_key: 'team_name', optional: true
  has_many :group_vaults, dependent: :destroy
  has_many :groups, through: :group_vaults
  has_many :user_vaults, dependent: :destroy
  has_many :users, through: :user_vaults
  belongs_to :user, optional: true
  has_many :vault_items, dependent: :destroy
  has_many :login_items, dependent: :destroy
  has_many :credit_card_items, dependent: :destroy
  has_many :server_items, dependent: :destroy
  has_many :vault_admin_keys, dependent: :destroy

  scope :not_shared, -> { where(is_shared: false) }
  scope :shared,     -> { where(is_shared: true) }

  def self.find_by_vault_id(vault_id)
    find_by(id: vault_id)
  end

  def self.get_all_vaults_for_admin(user)
    user.vaults.not_shared | (user.vaults | user.team.vaults).sort_by { |vault| vault[:title].downcase }
  end

  def self.get_all_vaults_for_users(user)
    vaults = user.vaults.not_shared
    user.groups.each { |group| vaults += group.vaults }
    user.vaults.not_shared + vaults.uniq
  end

  def self.create_personal_vault(user)
    vault = Vault.create(title: 'Personal', description: 'Your personal vault', user_id: user.id, is_shared: false, admin_keys: {})
    encoder = Encoder.new(user)
    vault_key = encoder.generate_sym_key(user)
    encrypted_vault_key = encoder.encrypt_sym_key(user, vault_key)
    UserVault.where(user: user, vault: vault).first_or_create(vault_key: encrypted_vault_key)
  end

  def self.search_vaults(search_query, user)
    vaults = []
    user.team.vaults.each do |vault|
      vaults.push(vault.vault_items.where('title ILIKE (?)', search_query))
    end
    vaults
  end

  def get_all_team_vaults(team_id)
    Vault.where(team_id: team_id).order(created_at: :desc)
  end

  def self.generate_report(vault, report_file_location)
    vault_items = vault.vault_items

    pdf = VaultInformationPdf.new(vault, vault_items)
    pdf.render_file File.join(report_file_location)
  end
end
