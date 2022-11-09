# frozen_string_literal: true

module User::Operation
  class Destroy < Trailblazer::Operation
    step Model(User, :find_by, :id)
    step Policy::Pundit(User::Policy::UserPolicy, :destroy?)
    step :destroy!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def destroy!(options, model:, **)
      options['model.response'] = :no_content
      model.destroy
      result = Result.new(!model.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.delete_user',
        action_type: 'User',
        action_act: 'Delete',
        actor_action: 'Deleted user',
        subj1_id: model.id,
        subj1_title: model.email
      )
    end
  end
end
