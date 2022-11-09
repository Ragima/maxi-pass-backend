# frozen_string_literal: true

module User::Operation
  class UsersResetPassword < Trailblazer::Operation
    step Policy::Pundit(User::Policy::UserPolicy, :users_reset_password?)
    step :model!
    success :serialized_model!

    def model!(options, current_user:, **)
      options[:model] = model = current_user.team.users
                                            .where(invitation_token: nil, reset_pass: true)
                                            .order(role_id: :asc, first_name: :asc)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = User::Representer::Index.new(model).to_hash
    end
  end
end