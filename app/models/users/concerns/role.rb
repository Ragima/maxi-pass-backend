# frozen_string_literal: true

module Users
  module Concerns
    module Role
      extend ActiveSupport::Concern

      def admin?
        %w[admin support].include?(role_id)
      end

      def support?
        role_id == 'support'
      end

      def vault_admin?(vault)
        admin? && team == vault.team
      end

      def private_vault?(vault)
        self == vault.user && vault.is_shared != true
      end

      def admin_as_user?
        role_id == 'admin' && temp
      end

      def lead?
        group_users.where(role: 'lead').exists?
      end

      def vault_admin_or_lead?(vault)
        return true if vault_admin?(vault)

        vault.groups.find_each do |group|
          return true if group_lead?(group)
        end
      end

      def vault_writer?(vault)
        if support?
          return (vault.users.where(id: id).present? || private_vault?(vault) || group_member?(vault.groups))
        end

        return true if vault_admin?(vault) || private_vault?(vault) || user_vaults.exists?(vault: vault, vault_writer: true)

        vault.groups.find_each do |group|
          return true if group_lead?(group)
        end
      end

      def vault_reader?(vault)
        if support?
          return (vault.users.where(id: id).present? || private_vault?(vault) || group_member?(vault.groups))
        end

        return true if vault_admin?(vault) || private_vault?(vault) || user_vaults.exists?(vault: vault)

        vault.groups.find_each do |group|
          return true if group_member?(group)
        end
      end

      def vault_item_writer?(item)
        if support?
          return (vault.users.where(id: id).present? || private_vault?(vault) || group_member?(vault.groups))
        end

        admin? || item.only_for_admins != true
      end

      def group_member?(group)
        group_users.exists?(group: group)
      end

      def group_lead?(group)
        return false if group.nil?

        [group, *group.ancestors].each do |self_or_ancestor|
          return true if group_users.exists?(group: self_or_ancestor, role: 'lead')
        end
        false
      end

      def user_lead?(user)
        return false if user.nil?

        lead_users_ids.include?(user)
      end

      def vault_lead?(vault)
        return false if vault.nil?

        vault.groups.find_each(&method(:group_lead?))
      end

    end
  end
end
