# frozen_string_literal: true

module Api::V1
  class GroupVaultsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase

    def create
      endpoint operation: GroupVault::Operation::Create,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: GroupVault::Operation::Destroy,
               options: { current_user: current_user }
    end
  end
end
