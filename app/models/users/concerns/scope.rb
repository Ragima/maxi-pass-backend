# frozen_string_literal: true

module Users
  module Concerns
    module Scope
      extend ActiveSupport::Concern

      # User Vault scopes

      def private_vaults_ids
        vaults.where(user: self, is_shared: false).pluck(:id)
      end

      def shared_vaults_ids
        vaults.where(is_shared: true).pluck(:id)
      end

      def team_vaults_ids
        team.vaults.pluck(:id)
      end

      def group_vaults_ids
        vaults = []
        groups.find_each do |group|
          vaults |= group.vaults.pluck(:id)
        end
        vaults
      end

      def lead_users_ids
        user_ids = []
        group_users.where(role: 'lead').find_each do |group_user|
          [group_user.group, *group_user.group.descendants].each do |self_or_descendant|
            user_ids |= self_or_descendant.users
          end
        end
        user_ids
      end

      def lead_groups_ids
        group_ids = []
        group_users.where(role: 'lead').find_each do |group_user|
          group_ids |= group_user.group.self_and_descendant_ids
        end
        group_ids
      end

      def admins_vaults
        Vault.where(id: [private_vaults_ids | team_vaults_ids]).order(is_shared: :asc).order(title: :asc)
      end

      def admins_vaults_without_personal
        Vault.where(id: team_vaults_ids).order(is_shared: :asc).order(title: :asc)
      end

      def users_vaults
        Vault.where(id: [private_vaults_ids | shared_vaults_ids | group_vaults_ids]).order(is_shared: :asc).order(title: :asc)
      end

      def users_vaults_without_personal
        Vault.where(id: [shared_vaults_ids | group_vaults_ids]).order(is_shared: :asc).order(title: :asc)
      end

      # User Group scopes

      def admins_groups
        team.groups
      end

      def leads_groups
        team.groups.where(id: lead_groups_ids)
      end

      # User Users scopes

      def admins_users
        team.users.where(invitation_token: nil).where.not(id: id).order("role_id = 0 DESC, role_id = 2 DESC, role_id = 1 DESC")
      end

      def leads_users
        team.users.where(id: lead_users_ids, invitation_token: nil).where.not(id: id).order(role_id: :asc).order("role_id = 0 DESC, role_id = 2 DESC, role_id = 1 DESC")
      end

      def support_users
        team.users.where(invitation_token: nil, role_id: 1).where.not(id: id).order(role_id: :asc).order("role_id = 0 DESC, role_id = 2 DESC, role_id = 1 DESC")
      end

    end
  end
end
