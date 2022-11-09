# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include Authenticator
  include SimpleEndpoint::Controller
  include Trailblazer::Rails::Controller

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :protect_with_master_key!
  before_action :set_raven_context
  skip_before_action :protect_with_master_key!, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def set_raven_context
    Raven.user_context(id: current_user&.id)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password first_name last_name temp support_personal_vaults])
    devise_parameter_sanitizer.permit(:invite, keys: %i[email invitation_token team_name extension_access])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

  private

  def user_not_authorized(exception)
    message = if exception.policy.class.to_s.underscore
                [I18n.t('pundit.feature_disabled', feature: exception.message)]
              else
                [I18n.t('pundit.unauthorized')]
              end
    render json: {
      errors: [message]
    }, status: :forbidden
  end

  def protect_with_master_key!
    @master_key ||= request.headers['master-key']
    render_unauthorized unless @master_key
  end

  def default_handler
    {
      created: ->(result) { render json: result[:serialized_model], status: :created },
      success: ->(result) { render json: result[:serialized_model], status: :ok },
      invalid: ->(result) { render json: { errors: result['contract.default'].errors.full_messages }, status: :unprocessable_entity },
      not_found: ->(_result) { head(:not_found) },
      no_content: ->(_result) { head(:no_content) },
      unauthenticated: ->(_result) { head(:forbidden) }
    }
  end

  def default_cases
    {
      present: ->(result) { result.success? && result['present'] },
      created: ->(result) { result.success? && result['model.action'] == :new },
      no_content: ->(result) { result.success? && result['model.response'] == :no_content },
      success: ->(result) { result.success? },
      not_found: ->(result) { result.failure? && result['result.model'] && result['result.model'].failure? },
      unauthenticated: ->(result) { result.failure? && result['result.policy.default'] && result['result.policy.default'].failure? },
      invalid: ->(result) { result.failure? }
    }
  end

end
