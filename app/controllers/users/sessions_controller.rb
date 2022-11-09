# frozen_string_literal: true

module Users
  class SessionsController < DeviseTokenAuth::SessionsController
    include Users::Concerns::ResourceFinder

    skip_before_action :authenticate_user!, only: [:create]

    def create
      # Check
      fields = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys)

      @resource = nil
      unless fields.empty?
        q_values = get_case_insensitive_field_from_resource_params(fields)

        @resource = find_resource(q_values)
      end

      return render_create_error_extension_user if @resource&.extension_access && params[:extension_access].nil?

      if @resource && valid_params?(q_values) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        valid_password = @resource.valid_password?(resource_params[:password])

        if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
          return render_create_error_bad_credentials
        end

        if @resource.team.otp_required_for_login
          unless @resource.validate_and_consume_otp!(resource_params[:otp_attempt], otp_secret: @resource.otp_secret)
            return render json: { errors: [I18n.t('sessions.otp_token_invalid')] }, status: 403
          end
        end

        @resource.temp_phrase = params[:password]
        @resource.generate_master_key
        session_key = @resource.generate_session_key
        @client_id, @token = @resource.create_token(session_key: session_key)
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success

        activity = ActivityService.new(@resource).call(key: 'user.logged_in',
                                                       action_type: 'User',
                                                       action_act: 'Login',
                                                       actor_action: 'logged in')
        AdminMailer::Operation::Create.call(current_user: @resource, activity: activity)
      elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        if @resource.respond_to?(:locked_at) && @resource.locked_at
          render_create_error_account_locked
        elsif @resource.blocked
          render_create_error_account_blocked
        else
          render_create_error_not_confirmed
        end
      else
        render_create_error_bad_credentials
      end
    end

    protected

    def valid_params?(q_values)
      q_values.keys.each do |q_value|
        return false if q_value.blank? || q_values[q_value].blank?
      end
      !(resource_params[:password].blank? || resource_params[:team_name].blank?)
    end

    def render_create_success
      render json: User::Representer::Show.new(@resource).to_hash, status: 200
    end

    def render_create_error_account_locked
      render_error(401, I18n.t('sessions.account_lock_msg'))
    end

    def render_create_error_account_blocked
      render_error(401, I18n.t('sessions.account_block_msg'))
    end

    def render_create_error_extension_user
      render_error(401, I18n.t('sessions.extension'))
    end
  end
end
