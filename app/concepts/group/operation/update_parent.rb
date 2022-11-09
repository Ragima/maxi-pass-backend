# frozen_string_literal: true

module Group::Operation
  class UpdateParent < Trailblazer::Operation
    step Model(Group, :find_by_group_id, :group_id)
    step Policy::Guard(:update_descendants?)
    step Policy::Pundit(Group::Policy::GroupPolicy, :update_parent?)
    step :update_parent!
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def update_descendants?(options, params:, current_user:, **)
      options[:parent] = parent_group = Group.find_by(id: params[:parent_group_id])
      return false if parent_group.nil?

      Group::Policy::GroupPolicy.new(current_user, parent_group).update_descendants?
    end

    def update_parent!(_options, model:, parent:, current_user:, **)
      return true if model.parent == parent

      model.parent = parent
      if (result = model.save)
        encoder = Encoder.new(current_user)
        model.ancestors.find_each do |self_or_ancestor|
          self_or_ancestor.users.find_each do |user|
            [model, *model.descendants].each do |self_or_descendant|
              group_key = encoder.decrypted_group_key(self_or_descendant)
              group_user = GroupUser.where(user: user, group: self_or_descendant).first_or_initialize
              encoder.assign_group_user_key(user, group_user, group_key)
              group_user.save
            end
          end
        end
      end
      result
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Group::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, model:, parent:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.added_group_to_group',
        action_type: 'Group',
        action_act: 'Add Group',
        actor_action: 'added group',
        subj1_id: model.id,
        subj1_title: model.name,
        subj1_action: 'to group',
        subj2_id: parent.id,
        subj2_title: parent.name
      )
    end
  end
end
