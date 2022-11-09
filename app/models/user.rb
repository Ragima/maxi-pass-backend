# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => Rails.application.credentials[:otp_secret]

  include Users::Concerns::User
  include Users::Concerns::Role
  include Users::Concerns::Scope
  include PublicActivity::Common
  include Users::Concerns::DeviseTokenAuth

  devise :database_authenticatable, :invitable, :trackable, :confirmable,
         :password_archivable, :registerable, :recoverable, :lockable,
         authentication_keys: %i[team_name email],
         case_insensitive_keys: %i[email]

  attr_accessor :alert, :user_private_key, :group_keys, :vault_keys, :master_key, :temp_phrase, :accept_to, :invited_by_name

  enum role_id: %i[admin user support],_prefix: :role

  belongs_to :team, foreign_key: 'team_name', optional: true

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :user_vaults, dependent: :destroy
  has_many :team_vaults, through: :team, class_name: 'Vault', source: :vaults
  has_many :group_vaults, through: :groups, class_name: 'Vault', source: :vaults
  has_many :vaults, through: :user_vaults, class_name: 'Vault', source: :vault
  has_many :group_admin_keys, dependent: :destroy
  has_many :vault_admin_keys, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscription_actions, through: :subscriptions

  NAME_LENGTH_MAXIMUM = 50
  NAME_REGEX_VALIDATE = /\A[-a-zA-ZёЁа-яА-Я0-9'`"\s_]{1,#{NAME_LENGTH_MAXIMUM}}\z/.freeze
  NAME_MESSAGE = I18n.t('user.name.validation', name_length: NAME_LENGTH_MAXIMUM)
  EMAIL_REGEX_VALIDATE = /\A[^@\s]+@[^@\s]+\z/.freeze
  PASSWORD_FORMAT = /\A(?=.{16,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/.freeze
  PASSWORD_MESSAGE = I18n.t('user.password.validation')
  TEMP_LENGTH_MINIMUM = 1
  TEMP_LENGTH_MAXIMUM = 50

  before_save :downcase_email
  before_validation :sync_uid
  before_save :sync_name
  before_save :sync_password_changed_at

  before_destroy :destroy_private_vaults

  validates :email, presence: true, format: { with: EMAIL_REGEX_VALIDATE }
  validates_uniqueness_of :email, scope: :team_name, unless: -> { team_name.blank? }
  validates_uniqueness_of :email, scope: :temp, unless: -> { temp.blank? }

  validates :first_name, :last_name,
            format: { with: NAME_REGEX_VALIDATE, message: I18n.t('user.name.validation', name_length: NAME_LENGTH_MAXIMUM) },
            allow_nil: true

  validate :password_complexity

  def password_complexity
    errors.add :password, I18n.t('user.password.validation') unless password.blank? || password =~ PASSWORD_FORMAT
  end

  def active_for_authentication?
    super && !reset_pass && !change_pass && !blocked
  end

  def self.find_by_user_id(user_id)
    find_by(id: user_id)
  end

  def self.find_by_reset_password_token(token)
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
    find_by(reset_password_token: reset_password_token)
  end

  def get_vault_users
    @users = []
    vaults.each do |vault|
      @users += vault.users
    end
    @users.reject! { |user| user.id == @current_user.id }.uniq
  end

  def all_vaults
    all_vaults = vaults | group_vaults
    all_vaults |= team_vaults if admin? && !admin_as_user?
    all_vaults
  end

  def all_login_items
    vaults = all_vaults
    all_vault_items = []
    vaults.each { |vault| all_vault_items.concat(vault.login_items) }
    all_vault_items = all_vault_items.reject(&:only_for_admins) unless admin? && !admin_as_user?
    all_vault_items
  end

  def build_confirm_auth_url(base_url, args)
    "#{base_url}?#{args.to_query}"
  end

  def delete_user_from_group(group_id, user)
    group = team.groups.find_by(id: group_id)
    group.users
    group.users.delete(user)
  end

  def destroy_private_vaults
    vaults.where(is_shared: false).each(&:destroy)
  end

  def accept_to
    invitation_due_at
  end

  def invited_by_name
    invited_by&.name
  end

  def two_factor_url
    label = "#{ENV['APP_NAME']}:#{email}"
    otp_provisioning_uri(label, issuer: ENV['APP_NAME'])
  end

  def activate_otp
    self.otp_required_for_login = true
    self.otp_secret             = User.generate_otp_secret
    save
  end

  def deactivate_otp
    self.otp_required_for_login = false
    self.otp_secret             = nil
    save
  end

  private

  def downcase_email
    self.email = email.strip.downcase
  end

  def sync_uid
    self.uid = "#{team_name}_#{email}"
  end

  def sync_name
    return if !name.blank? || first_name.blank? || last_name.blank?

    self.name = "#{first_name} #{last_name}"
  end

  def sync_password_changed_at
    return unless password_changed_at.blank?

    self.password_changed_at = Time.now.utc
  end

  def self.generate_report(user, report_file_location)
    pdf = UserInformationPdf.new(user)
    pdf.render_file File.join(report_file_location)
  end
end
