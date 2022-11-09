# frozen_string_literal: true

class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
  skip_before_action :authenticate_user!, only: [:create]
  RESERVED_NAMES = %w[about contact help support recover].freeze

  def create
    return render json: { errors: [I18n.t('registration.invalid_team_name')] }, status: :unprocessable_entity if RESERVED_NAMES.include?(params[:temp].try(:downcase))

    team = Team.find_by('LOWER(name) = ?', params[:temp].try(:downcase))
    return render json: { errors: [I18n.t('registration.team_name_already_exist')] }, status: 422 if team

    super do
      generate_keys_for_user(@resource, params[:password])
      Vault.create_personal_vault(@resource) if @resource.support_personal_vaults
    end
  end

  def generate_keys_for_user(resource, password)
    @encoder ||= Encoder.new(resource)
    resource.name = "#{resource&.first_name} #{resource&.last_name}" if resource.name.blank?

    rsa_key = @encoder.generate_user_private_key
    public_key = rsa_key.public_key.to_pem
    private_key = @encoder.encrypt_user_private_key(resource, password, rsa_key)

    resource.update_attributes(public_key: public_key,
                               private_key: private_key)
  end

  protected

  def build_resource
    email = if resource_class.case_insensitive_keys.include?(:email)
              sign_up_params[:email].try(:downcase)
            else
              sign_up_params[:email]
            end
    @resource = resource_class.find_by(email: email, temp: sign_up_params[:temp]) || resource_class.new(sign_up_params)
    @resource.email = email
    @resource.provider = provider
  end

  def render_create_success
    render json: resource_data, status: 201
  end

  def render_create_error
    render json: { status: 'error', errors: @resource.errors.full_messages }, status: 422
  end

  def render_create_error_email_already_exists
    render json: { status: 'error', errors: [I18n.t('registration.email_already_exist')] }, status: 422
  end
end
