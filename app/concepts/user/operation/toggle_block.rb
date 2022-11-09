# frozen_string_literal: true

module User::Operation
  class ToggleBlock < Trailblazer::Operation
    step Model(User, :find_by_user_id, :user_id)
    step Policy::Pundit(User::Policy::UserPolicy, :block?)
    step :toggle_block!
    step ->(options, **) { options['model.response'] = :no_content }
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def toggle_block!(options, model:, **)
      options[:blocked_action] = !model.blocked
      model.update_attributes(blocked: !model.blocked)
    end

    def write_activity!(options, current_user:, model:, blocked_action:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.toggle_block',
        action_type: 'User',
        action_act: blocked_action ? 'Block' : 'Unblock',
        actor_action: blocked_action ? 'blocked' : 'unblocked',
        subj1_id: model.id,
        subj1_title: model.email
      )
    end
  end
end
