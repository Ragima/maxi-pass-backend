# frozen_string_literal: true

module User::Operation
  class Invitations < Trailblazer::Operation
    step Policy::Pundit(User::Policy::UserPolicy, :invitations?)
    step :model!
    success :serialized_model!

    def model!(options, current_user:, **)
      options[:model] = model = current_user.team.users.where.not(invitation_token: nil)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = User::Representer::Invitations.new(model).to_hash
    end
  end
end