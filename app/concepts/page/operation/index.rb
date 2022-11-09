# frozen_string_literal: true

module Page::Operation
  class Home < Trailblazer::Operation
    step :serialized_model!
    step :assign_vaults!
    step :assign_groups!
    step :assign_invitations!

    def serialized_model!(options, **)
      options[:serialized_model] = {}
    end

    def assign_vaults!(_options, serialized_model:, current_user:, **)
      vaults = current_user.admin? ? current_user.admins_vaults : current_user.users_vaults
      serialized_model['vaults'] = Vault::Representer::ShortIndex.new(vaults).to_hash
    end

    def assign_groups!(_options, serialized_model:, current_user:, **)
      return true unless current_user.admin? || current_user.lead?

      groups = current_user.admin? ? current_user.admins_groups : current_user.leads_groups
      serialized_model['groups'] = Group::Representer::ShortIndex.new(groups).to_hash
    end

    def assign_invitations!(_options, serialized_model:, current_user:, **)
      return true unless current_user.admin?

      invitations = current_user.team.users.where.not(invitation_token: nil)
      serialized_model['invitations'] = User::Representer::Invitations.new(invitations).to_hash
    end
  end
end