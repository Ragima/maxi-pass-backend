# frozen_string_literal: true

module User::Operation
  class Update < Trailblazer::Operation
    step Model(User, :find_by, :id)
    step Policy::Pundit(User::Policy::UserPolicy, :update?)
    step Contract::Build(constant: User::Contract::Update)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    success :serialized_model!

    def serialized_model!(options, model:, **)
      options[:serialized_model] = User::Representer::Show.new(model).to_hash
    end
  end
end