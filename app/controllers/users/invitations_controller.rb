# frozen_string_literal: false

module Users
  class InvitationsController < Devise::InvitationsController
    include InviteMethods
    before_action :authenticate_user!, only: %i[create index destroy resend_invitation]
    before_action :resource_from_invitation_token, only: %i[edit update]
    before_action :set_invite, only: %i[destroy resend_invitation]

    def edit
      redirect_url = "#{ENV['INVITATION_URL']}?invitation_token=#{params[:invitation_token]}"
      redirect_to redirect_url if params[:invitation_token].present?
    end

    def update
      self.resource = accept_resource
      invitation_accepted = resource.errors.empty?
      yield resource if block_given?
      @resource.reload
      if invitation_accepted
        if Devise.allow_insecure_sign_in_after_accept
          encoder = Encoder.new(@resource)
          rsa_key = encoder.generate_user_private_key
          public_key = rsa_key.public_key.to_pem
          private_key = encoder.encrypt_user_private_key(@resource, update_resource_params[:password], rsa_key)
          @resource.assign_attributes(update_resource_params
                                          .merge(name: "#{update_resource_params[:first_name]} #{update_resource_params[:last_name]}",
                                                 temp_phrase: update_resource_params[:password],
                                                 invitation_token: nil,
                                                 public_key: public_key,
                                                 private_key: private_key))
          Vault.create_personal_vault(@resource) if @resource.team.support_personal_vaults
          @resource.generate_master_key
          session_key = @resource.generate_session_key
          @client_id, @token = @resource.create_token(session_key: session_key)
          @resource.save

          activity = ActivityService.new(@resource).call(key: 'user.accept_invitation',
                                                         action_type: 'User',
                                                         action_act: 'Accept Invitation',
                                                         actor_action: 'accepted invitation from',
                                                         subj1_id: @resource.invited_by_id,
                                                         subj1_title: @resource.invited_by&.email)
          AdminMailer::Operation::Create.call(current_user: @resource, activity: activity)
          if @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
            return render_create_error_bad_credentials
          end

          if @resource.extension_access
            return render_create_error_extension_user
          else
            sign_in(resource_name, @resource, store: false, bypass: false)
            render json: User::Representer::Show.new(@resource).to_hash, status: 201
          end
        else
          head :no_content
        end
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create
      if @current_user.admin?
        self.resource = invite_resource do |u|
          u.otp_secret = User.generate_otp_secret if u.team.otp_required_for_login
        end

        resource_invited = resource.errors.empty?
        yield resource if block_given?
        if resource_invited
          resource.update!(role_id: 'user', team: @current_user.team)
          activity = ActivityService.new(current_user).call(key: 'user.create_invitation',
                                                            action_type: 'User',
                                                            action_act: 'Create Invitation',
                                                            actor_action: 'created invitation to',
                                                            subj1_id: resource.id,
                                                            subj1_title: resource.email)
          AdminMailer::Operation::Create.call(current_user: current_user, activity: activity)
          render json: User::Representer::Invitation.new(resource).to_hash, status: 201
        else
          render json: { errors: resource.errors.full_messages }, status: 422
        end
      end
    end

    def destroy
      authorize @invitation, policy_class: InvitationPolicy
      if @invitation.destroy
        activity = ActivityService.new(current_user).call(key: 'user.delete_invitation',
                                                          action_type: 'User',
                                                          action_act: 'Delete Invitation',
                                                          actor_action: 'deleted invitation to',
                                                          subj1_id: @invitation.id,
                                                          subj1_title: @invitation.email)
        AdminMailer::Operation::Create.call(current_user: current_user, activity: activity)
        head :no_content
      else
        render json: { errors: @invitation.errors.full_messages }, status: 422
      end
    end

    def resend_invitation
      authorize @invitation, policy_class: InvitationPolicy
      @invitation.invite!
      @invitation.update!(role_id: 'user', team: @current_user.team)
      activity = ActivityService.new(current_user).call(key: 'user.resend_invitation',
                                                        action_type: 'User',
                                                        action_act: 'Resend Invitation',
                                                        actor_action: 'resent invitation to',
                                                        subj1_id: @invitation.id,
                                                        subj1_title: @invitation.email)
      AdminMailer::Operation::Create.call(current_user: current_user, activity: activity)
      render json: User::Representer::Invitation.new(@invitation).to_hash, status: 200
    end

    private

    def set_invite
      params_id = params[:id] || params[:user_id] || params[:invite_id]
      @invitation = @current_user.team.users.where('invitation_token is not null and id=?', params_id).first
      head(:not_found) if @invitation.nil?
    end

    def render_create_error_bad_credentials
      render json: { errors: [I18n.t('devise_token_auth.sessions.bad_credentials')] }, status: 401
    end

    def render_create_error_extension_user
      render json: { errors: [I18n.t('invitation.extension')] }, status: 401
    end

    def update_resource_params
      params.require(:invitation).permit(:invitation_token, :password, :first_name, :last_name)
    end
  end
end
