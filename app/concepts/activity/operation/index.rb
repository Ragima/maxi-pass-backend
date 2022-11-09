# frozen_string_literal: true

module Activity::Operation
  class Index < Trailblazer::Operation
    step Policy::Pundit(ActivityPolicy, :index?)
    step :model!
    success :serialized_model!
    step :assign_users!

    def model!(options, params:, current_user:, **)
      options[:model] = Activity.with_pagination(page(params), per_page(params), params, current_user)
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = serialized_model = Activity::Representer::Index.new(model).to_hash
      serialized_model[:total_pages] = model.total_pages
      serialized_model[:current_page] = model.current_page
    end

    def assign_users!(_options, serialized_model:, current_user:, **)
      users = current_user.admin? ? current_user.admins_users : current_user.leads_users
      serialized_model['users'] = User::Representer::Index.new(users).to_hash
    end

    private

    def page(params)
      params[:page] || 1
    end

    def per_page(params)
      params[:per_page] || 20
    end
  end
end
