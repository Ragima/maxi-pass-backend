# frozen_string_literal: true

module Team::Operation
  class EnableTwoFactor < Trailblazer::Operation
    step :model!
    step Policy::Pundit(Team::Policy::TeamPolicy, :enable_two_factor?)
    success :update_users
    success :enable_two_factor_auth!
    success :serialized_model!


    def enable_two_factor_auth!(_options, model:, **)
      model.update_attributes(otp_required_for_login: true)
    end

    def model!(options, params:, **)
      options[:model] = model = Team.find_by(name: params[:team_name])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def update_users(options, model:, **)
      if model.otp_required_for_login
        options['model.response'] = :no_content
      else
        EnableTwoFactorJob.perform_later(model.name)
      end
    end

    def serialized_model!(options, model:, current_user:, **)
      options[:serialized_model] = Team::Representer::Show.new(model).to_hash(user_options: { current_user: current_user })
    end
  end
end