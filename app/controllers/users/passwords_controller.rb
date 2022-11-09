# frozen_string_literal: true

module Users
  class PasswordsController < DeviseTokenAuth::PasswordsController
    skip_before_action :authenticate_user!, only: %i[create edit]
    before_action :set_user_by_token, only: %i[update]
    skip_after_action :update_auth_header, only: %i[create edit]

    def create
      run Password::Operation::Create do |result|
        return result[:model].send_reset_password_instructions(
          result[:instructions]
        )
      end
      render json: { errors: [I18n.t('passwords.user_not_found')] }, status: :not_found
    end

    def edit
      run Password::Operation::Accept do |result|
        redirect_header_options = { reset_password: true }
        redirect_headers = build_redirect_headers(result[:token],
                                                  result[:client_id],
                                                  redirect_header_options)
        return redirect_to(result[:model].build_auth_url(
                             params.fetch(:redirect_url, DeviseTokenAuth.default_password_reset_url), redirect_headers
                           ))
      end

      head(:not_found)
    end

    def update
      endpoint operation: Password::Operation::Update,
               options: { current_user: current_user },
               different_handler: update_password_handler
    end

    private

    def update_password_handler
      {
          success: ->(_) { render json: { messages: [I18n.t('passwords.reset_password_success')] } },
          invalid: ->(result) { render json: { errors: result['contract.default'].errors.full_messages }, status: :unprocessable_entity }
      }
    end
  end
end
