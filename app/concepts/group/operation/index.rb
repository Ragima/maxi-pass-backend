# frozen_string_literal: true

module Group::Operation
  class Index < Trailblazer::Operation
    step Policy::Pundit(Group::Policy::GroupPolicy, :index?)
    success :define_scope!
    step :model!
    success :serialized_model!

    def define_scope!(options, current_user:, **)
      options[:groups_scope] = groups_scope = if current_user.admin?
                                                lambda(&:admins_groups)
                                              elsif current_user.lead?
                                                lambda(&:leads_groups)
                                              end
      !groups_scope.nil?
    end

    def model!(options, groups_scope:, current_user:, **)
      options[:model] = model = groups_scope.call(current_user).order(name: :asc)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Group::Representer::Index.new(model).to_hash
    end
  end
end