# frozen_string_literal: true

module Group::Operation
  class Destroy < Trailblazer::Operation
    step Model(Group, :find_by, :id)
    step Policy::Pundit(Group::Policy::GroupPolicy, :destroy?)
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
        key: 'user.delete_group',
        action_type: 'Group',
        action_act: 'Delete',
        actor_action: 'Deleted group',
        subj1_id: model.id,
        subj1_title: model.name
      )
    end
  end
end
