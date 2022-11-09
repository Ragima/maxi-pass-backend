module Group::Operation
  class DeleteParent < Trailblazer::Operation
    step Model(Group, :find_by_group_id, :group_id)
    step Policy::Guard(:update_descendants?)
    step Policy::Pundit(Group::Policy::GroupPolicy, :delete_parent?)
    step :remove_parent!
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def update_descendants?(options, params:, current_user:, **)
      options[:parent] = parent_group = Group.find_by(id: params[:parent_group_id])
      return false if parent_group.nil?

      Group::Policy::GroupPolicy.new(current_user, parent_group).delete_parent?
    end

    def remove_parent!(_options, model:, parent:, **)
      return true if model.parent.nil?

      model.parent = nil
      if model.valid?
        parent.descendants.find_each do |self_or_descendant|
          self_or_descendant.users.find_each do |user|
            [parent, *parent.ancestors].each do |self_or_ancestor|
              group_user = GroupUser.where(user: user, group: self_or_ancestor).first
              next if group_user.nil?

              group_user.destroy if group_user.role_user?
            end
          end
        end
      end
      model.save
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Group::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, model:, parent:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.remove_parent_group',
        action_type: 'Group',
        action_act: 'Remove Parent Group',
        actor_action: 'remove parent group',
        subj1_id: model.id,
        subj1_title: model.name,
        subj1_action: 'to group',
        subj2_id: parent.id,
        subj2_title: parent.name
      )
    end
  end
end