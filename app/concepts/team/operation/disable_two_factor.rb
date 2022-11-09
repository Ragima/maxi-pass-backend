# frozen_string_literal: true

module Team::Operation
  class DisableTwoFactor < Trailblazer::Operation
    step :model!
    step Policy::Pundit(Team::Policy::TeamPolicy, :disable_two_factor?)
    success :disable_two_factor_auth!
    success :serialized_model!

    def disable_two_factor_auth!(_options, model:, **)
      model.update_attributes(otp_required_for_login: false)
    end

    def model!(options, params:, **)
      options[:model] = model = Team.find_by(name: params[:team_name])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, current_user:, **)
      options[:serialized_model] = Team::Representer::Show.new(model).to_hash(user_options: { current_user: current_user })
    end
  end
end