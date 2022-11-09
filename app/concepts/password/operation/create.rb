# frozen_string_literal: true

module Password::Operation
  class Create < Trailblazer::Operation
    Contract::Build()
    step :model!
    step :create_instructions!

    def model!(options, params:, **)
      options[:model] = model = User.find_by(email: params[:email], team_name: params[:team_name])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def create_instructions!(options, params:, model:, **)
      options[:instructions] = {
        email: model.email,
        provider: 'email',
        redirect_url: params.fetch(:redirect_url, DeviseTokenAuth.default_password_reset_url),
        client_config: params[:client_config]
      }
    end
  end
end
