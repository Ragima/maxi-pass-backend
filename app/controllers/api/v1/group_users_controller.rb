# frozen_string_literal: true

module Api::V1
  class GroupUsersController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase

    def create
      endpoint operation: GroupUser::Operation::Create,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: GroupUser::Operation::Destroy,
               options: { current_user: current_user }
    end

    def change_role
      endpoint operation: GroupUser::Operation::ChangeRole,
               options: { current_user: current_user }
    end
  end
end
