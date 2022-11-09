# frozen_string_literal: true

module Api::V1
  class UserVaultsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase

    def create
      endpoint operation: UserVault::Operation::Create,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: UserVault::Operation::Destroy,
               options: { current_user: current_user }
    end

    def change_role
      endpoint operation: UserVault::Operation::ChangeRole,
               options: { current_user: current_user }
    end
  end
end
