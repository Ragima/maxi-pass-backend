# frozen_string_literal: true

module GroupUser::Contract
  class ChangeRole < Reform::Form

    property :role

    validates :role, inclusion: { in: %w[lead user] }
  end
end