# frozen_string_literal: true

module Api::V1
  class GroupsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase
    before_action :set_group, only: %i[generate_report]
    before_action :set_user, only: %i[generate_report]

    def index
      endpoint operation: Group::Operation::Index,
               options: { current_user: current_user }
    end

    def show
      endpoint operation: Group::Operation::Show,
               options: { current_user: current_user }
    end

    def create
      endpoint operation: Group::Operation::Create,
               options: { current_user: current_user }
    end

    def update
      endpoint operation: Group::Operation::Update,
               options: { current_user: current_user }
    end

    def update_parent
      endpoint operation: Group::Operation::UpdateParent,
               options: { current_user: current_user }
    end

    def delete_parent
      endpoint operation: Group::Operation::DeleteParent,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: Group::Operation::Destroy,
               options: { current_user: current_user }
    end

    def generate_report
      authorize @group
      ReportJob.perform_later(@group.id, @user.id, current_user.id, "Group")
      render json: { status: 200 }
    end

    private

    def set_group
      @group = @current_user.team.groups.find_by(id: params[:group_id])
      head(:not_found) if @group.nil?
    end

    def set_user
      @user = @current_user.team.users.find_by(id: params[:user_id])
      head(:not_found) if @user.nil?
    end
  end
end
