# frozen_string_literal: true

class Users::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  skip_before_action :authenticate_user!

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    return head(:not_found) if resource.id.nil? || resource.team_name

    return render json: { errors: [I18n.t('registration.team_name_already_exist')] } if Team.find_by('LOWER(name) = ?', resource.temp&.downcase)&.persisted?

    @team = Team.new(name: resource&.temp, support_personal_vaults: resource.support_personal_vaults)
    if @team.save
      @team.users << resource
      resource.update(temp: nil, role_id: 'admin')
      redirect_header_options = { account_confirmation_success: true, team: resource.team_name }

      ActivityService.new(resource).call(key: 'user.create_team',
                                         action_type: 'Team',
                                         action_act: 'Create',
                                         actor_action: 'created team',
                                         subj1_id: @team.name,
                                         subj1_title: @team.name)

      redirect_to(resource.build_confirm_auth_url(ENV['CONFIRM_SUCCESS_URL'], redirect_header_options))
    else
      render json: { errors: @team.errors.full_messages }, status: 422
    end

  end
end
