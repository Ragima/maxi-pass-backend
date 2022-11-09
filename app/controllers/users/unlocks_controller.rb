# frozen_string_literal: true

class Users::UnlocksController < DeviseTokenAuth::UnlocksController
  prepend_before_action :require_no_authentication
  skip_before_action :authenticate_user!, only: %i[create show]

  def show
    @resource = resource_class.unlock_access_by_token(params[:unlock_token])

    if @resource&.id
      redirect_header_options = { unlock: true }
      redirect_to(DeviseTokenAuth::Url.generate(after_unlock_path_for(@resource),
                                                redirect_header_options))
    else
      render_show_error
    end
  end

  protected

  # The path used after unlocking the resource
  def after_unlock_path_for(resource)
    Rails.application.credentials.dig(:devise, :default_unlock_url)
  end
end
