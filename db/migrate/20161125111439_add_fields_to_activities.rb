# frozen_string_literal: true

class AddFieldsToActivities < ActiveRecord::Migration[5.2]
  def up
    change_table :activities do |t|
      t.string     :actor_role
      t.string     :actor_email
      t.string     :actor_action
      t.string     :subj1_id
      t.string     :subj1_title
      t.string     :subj1_action
      t.string     :subj2_id
      t.string     :subj2_title
      t.string     :subj2_action
      t.string     :subj3_id
      t.string     :subj3_title
      t.string     :action_type
      t.string     :action_act
    end

    # USER
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='created team',
            subj1_id = team_name,
            subj1_title = team_name,
            action_type = 'Team',
            action_act = 'Create'
        where key = 'user.create_team' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='sent invitation to user',
            subj1_id = trackable_id,
            subj1_title = (
                           SELECT substring(a.parameters from '%:invited_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Invite'
        where key = 'user.send_invitations' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='resent invitation to user',
            subj1_id = (
                           SELECT substring(a.parameters from '%:invite_resend_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:invite_resend_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Reinvite'
        where key = 'user.resend_invitation' and activities.actor_email is null or activities.actor_email='';
    SQL

    # !!!!!!!!!!!!!!
    execute <<-SQL
        UPDATE activities
        SET actor_email = (
                           SELECT substring(a.parameters from '%:invited_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            actor_action ='accepted invitation to team',
            subj1_id = team_name,
            subj1_title = team_name,
            action_type = 'User',
            action_act = 'Accept invitation'
        where key = 'user.accept_invitation' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='deleted invitation to user',
            subj1_id = trackable_id,
            subj1_title = (
                           SELECT substring(a.parameters from '%:invite_destroy_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Delete invitation'
        where key = 'user.delete_invitation' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='deleted user',
            subj1_title = (
                           SELECT substring(a.parameters from '%:user_destroy: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from the team',
            subj2_title = team_name,
            action_type = 'User',
            action_act = 'Delete user'
        where key = 'user.destroy_user' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='gave role of admin to user',
            subj1_id = (
                           SELECT substring(a.parameters from '%:user_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Change role'
        where key = 'user.change_role_to_admin' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='gave role of user to admin',
            subj1_id = (
                           SELECT substring(a.parameters from '%:user_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Change role'
        where key = 'user.change_role_to_user' and activities.actor_email is null or activities.actor_email='';
    SQL

    # !!!!
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.trackable_id=users.id),'someone'),
            actor_action ='gave the opportunity to edit the vault',
            subj1_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'to user',
            subj2_id = (
                           SELECT substring(a.parameters from '%:user_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Change role'
        where key = 'user.role_write_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    # !!!!
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='took the opportunity to edit the vault',
            subj1_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'to user',
            subj2_id = (
                           SELECT substring(a.parameters from '%:user_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'User',
            action_act = 'Change role'
        where key = 'user.role_read_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    # GROUPS
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='created group',
            subj1_id = (
                           SELECT substring(a.parameters from '%:group_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Create'
        where key = 'user.create_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='edited group s name from',
            subj1_title = (
                           SELECT substring(a.parameters from '%:group_old_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'to',
            subj2_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Edit'
        where key = 'user.edit_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='deleted group',
            subj1_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Delete'
        where key = 'user.destroy_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='added user',
            subj1_title = (
                           SELECT substring(a.parameters from '%:add_user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'to group',
            subj2_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Add user'
        where key = 'user.add_user_to_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='added access to vault',
            subj1_id = (
                           SELECT substring(a.parameters from '%:add_vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),

            subj1_title = (
                           SELECT substring(a.parameters from '%:add_vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'to group',
            subj2_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Add vault'
        where key = 'user.add_vault_to_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='removed user',
            subj1_title = (
                           SELECT substring(a.parameters from '%:remove_user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from group',
            subj2_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Remove user'
        where key = 'user.remove_user_from_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='removed vault',
            subj1_title = (
                           SELECT substring(a.parameters from '%:remove_vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from group',
            subj2_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Group',
            action_act = 'Remove vault'
        where key = 'user.remove_vault_from_group' and activities.actor_email is null or activities.actor_email='';
    SQL

    # VAULT
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='created vault',
            subj1_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Create'
        where key = 'user.create_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='edited vault',
             subj1_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Edit'
        where key = 'user.edit_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='deleted vault',
            subj1_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Delete'
        where key = 'user.destroy_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='added user',
            subj1_id = (
                           SELECT substring(a.parameters from '%:user_id: |"[0-9]+|"%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'access to vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Add user'
        where key = 'user.add_user_to_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='removed user',
            subj1_title = (
                           SELECT substring(a.parameters from '%:user_email: "?|"[-_@.+0-9a-zA-Z]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'access to vault',
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Remove user'
        where key = 'user.remove_user_from_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='gave group',
            subj1_id = (
                           SELECT substring(a.parameters from '%:group_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'access to vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Add group'
        where key = 'user.add_group_to_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='removed group',
            subj1_id = (
                           SELECT substring(a.parameters from '%:group_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:group_name: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'access to vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Remove group'
        where key = 'user.remove_group_from_vault' and activities.actor_email is null or activities.actor_email='';
    SQL

    # VAULT ITEM
    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='created vault item',
            subj1_id = (
                           SELECT substring(a.parameters from '%:item_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:item_title:"?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'in vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Create item'
        where key = 'user.create_login_item' or key='user.create_credit_card_item' or key='user.create_server_item'
            or key = 'user.create_login_item_personal' or key = 'user.create_credit_card_item_personal'
            or key  = 'user.create_server_item_personal'  and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='updated vault item',
            subj1_id = (
                           SELECT substring(a.parameters from '%:item_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:item_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'in vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Update item'
        where key = 'user.update_login_item' or key='user.update_credit_card_item' or key='user.update_server_item'
            or key = 'user.update_login_item_personal' or key = 'user.update_credit_card_item_personal'
            or key  = 'user.update_server_item_personal' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='removed vault item',
            subj1_id = (
                           SELECT substring(a.parameters from '%:item_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:item_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Update item'
        where key = 'user.destroy_login_item' or key='user.destroy_credit_card_item' or key='user.destroy_server_item' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='copied vault item',
            subj1_id = (
                           SELECT substring(a.parameters from '%:item_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:item_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id_from: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title_from: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_action = 'to vault',
            subj3_id = (
                           SELECT substring(a.parameters from '%:vault_id_to: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj3_title = (
                           SELECT substring(a.parameters from '%:vault_title_to: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Copy item'
        where key = 'user.copy_login_item' or key='user.copy_server_item' or key='user.copy_credit_card_item' and activities.actor_email is null or activities.actor_email='';
    SQL

    execute <<-SQL
        UPDATE activities
        SET actor_email = coalesce((SELECT users.email as email FROM users WHERE activities.owner_id=users.id),'someone'),
            actor_action ='moved vault item',
            subj1_id = (
                           SELECT substring(a.parameters from '%:item_id: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_title = (
                           SELECT substring(a.parameters from '%:item_title: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj1_action = 'from vault',
            subj2_id = (
                           SELECT substring(a.parameters from '%:vault_id_from: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_title = (
                           SELECT substring(a.parameters from '%:vault_title_from: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj2_action = 'to vault',
            subj3_id = (
                           SELECT substring(a.parameters from '%:vault_id_to: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            subj3_title = (
                           SELECT substring(a.parameters from '%:vault_title_to: "?|"[-@.+0-9a-zA-Zа-яА-Я\s]+|""?%' for '|')
                           from activities as a where a.id=activities.id
                          ),
            action_type = 'Vault',
            action_act = 'Move item'
        where key = 'user.move_login_item' or key='user.move_server_item' or key='user.move_credit_card_item' and activities.actor_email is null or activities.actor_email='';
    SQL
  end
end
