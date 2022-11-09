# frozen_string_literal: true

module GroupsHelper
  def create_group(user, params_hash = {})
    group = create :group, params_hash
    encoder = Encoder.new(user)
    group_key = encoder.generate_sym_key(user)
    encoder.assign_group_admin_keys(group, group_key)
    unless user.admin?
      group_user = GroupUser.where(user: user, group: group).first_or_initialize
      encoder.assign_group_user_key(user, group_user, group_key)
      group_user.save
    end
    group.save
    group
  end
end