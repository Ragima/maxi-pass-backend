class FillSubsriptionActions < ActiveRecord::Migration[5.2]
  def change
    actions = {
      'Credit card item': %w[Create Read Update Delete Copy Move],
      'Login item': %w[Create Read Update Delete Copy Move],
      'Server item': %w[Create Read Update Delete Copy Move],
      Vault: ['Create', 'Delete', 'Update', 'Change Role', 'Add User', 'Remove User'],
      Group: ['Create', 'Delete', 'Update', 'Change Role', 'Add User', 'Remove User', 'Add Vault', 'Remove Vault', 'Add Group'],
      User: ['Create Invitation', 'Accept Invitation', 'Delete Invitation', 'Resend Invitation', 'Login', 'Change Role', 'Delete', 'Block', 'Unblock']
    }
    actions_to_create = []
    actions.each do |key, value|
      value.each do |element|
        actions_to_create.push(entity_type: key, action_type: element)
      end
    end
    SubscriptionAction.import(actions_to_create)
  end
end
