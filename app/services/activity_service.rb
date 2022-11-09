# frozen_string_literal: true

class ActivityService
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def call(options)
    current_user.create_activity(owner: current_user,
                                 actor_role: current_user.role_id,
                                 actor_email: current_user.email,
                                 team_name: current_user.team_name,
                                 subj1_id: options[:subj1_id],
                                 subj1_title: options[:subj1_title],
                                 subj1_action: options[:subj1_action],
                                 subj2_id: options[:subj2_id],
                                 subj2_title: options[:subj2_title],
                                 subj2_action: options[:subj2_action],
                                 subj3_id: options[:subj3_id],
                                 subj3_title: options[:subj3_title],
                                 key: options[:key],
                                 action_type: options[:action_type],
                                 action_act: options[:action_act],
                                 actor_action: options[:actor_action],
                                 params: options[:params])
  end
end
