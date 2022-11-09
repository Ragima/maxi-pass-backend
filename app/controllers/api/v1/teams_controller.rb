# frozen_string_literal: true

module Api::V1
  class TeamsController < ApplicationController
    include KeysConcern
    skip_before_action :authenticate_user!, only: %i[check_two_factor]
    skip_before_action :protect_with_master_key!, only: %i[check_two_factor]
    before_action :decrypt_temp_phrase, only: %i[disable_two_factor enable_two_factor]
    before_action :set_team, only: %i[disable_two_factor enable_two_factor]

    def enable_two_factor
      endpoint operation: Team::Operation::EnableTwoFactor,
               options: { current_user: current_user }
    end

    def disable_two_factor
      endpoint operation: Team::Operation::DisableTwoFactor,
               options: { current_user: current_user }
    end

    def check_two_factor
      team = Team.find_by(name: params[:team_name])
      otp_required_for_login = team ? team.otp_required_for_login : false
      render json: { otp_required_for_login: otp_required_for_login }, status: 200
    end

    private

    def set_team
      @team = Team.find_by(name: params[:team_name])
      head(:not_found) if @team.nil?
    end
  end
end
