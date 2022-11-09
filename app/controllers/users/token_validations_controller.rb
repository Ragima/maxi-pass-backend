# frozen_string_literal: true

module Users
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    protected

    def render_validate_token_success
      render json: User::Representer::Show.new(@resource).to_hash, status: 200
    end
  end
end
