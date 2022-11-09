# frozen_string_literal: true

module Api::V1
  class UsersController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase
    before_action :set_user, only: %i[generate_report]
    before_action :set_report_receiver, only: %i[generate_report]

    def invitations
      endpoint operation: User::Operation::Invitations,
               options: { current_user: current_user }
    end

    def index
      endpoint operation: User::Operation::Index,
               options: { current_user: current_user }
    end

    def show
      endpoint operation: User::Operation::Show,
               options: { current_user: current_user }
    end

    def update
      endpoint operation: User::Operation::Update,
               options: { current_user: current_user }
    end

    def update_settings
      endpoint operation: User::Operation::UpdateSettings,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: User::Operation::Destroy,
               options: { current_user: current_user }
    end

    def users_reset_password
      endpoint operation: User::Operation::UsersResetPassword,
               options: { current_user: current_user }
    end

    def change_role
      endpoint operation: User::Operation::ChangeRole,
               options: { current_user: current_user }
    end

    def restore
      result = User::Operation::Restore.call(current_user: current_user, params: params)
      if result.success?
        PasswordMailer.send(:restore_completed, result[:model]).deliver_now
        head(:ok)
      else
        head(:not_found)
      end
    end

    def toggle_block
      endpoint operation: User::Operation::ToggleBlock,
               options: { current_user: current_user }
    end

    def generate_report
      authorize @user
      ReportJob.perform_later(@user.id, @report_receiver.id, current_user.id, "User")
      render json: { status: 200 }
    end

    private

    def set_user
      @user = @current_user.team.users.find_by(id: params[:user_id])
      head(:not_found) if @user.nil?
    end

    def set_report_receiver
      @report_receiver = @current_user.team.users.find_by(id: params[:report_receiver_id])
      head(:not_found) if @report_receiver.nil?
    end
  end
end
