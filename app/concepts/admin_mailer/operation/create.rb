# frozen_string_literal: true

module AdminMailer::Operation
  class Create < Trailblazer::Operation
    step :send_mails!

    def send_mails!(_options, current_user:, activity:, **)
      subscription_action = SubscriptionAction.find_by(entity_type: activity.action_type, action_type: activity.action_act)
      return true if subscription_action.nil?

      subscription_action.users
                         .where(role_id: 'admin', team_name: current_user.team_name)
                         .where.not(id: current_user.id).find_each do |admin|
        AdminMailer.send(:notification_email, admin, activity).deliver_later
      end
    end
  end
end
