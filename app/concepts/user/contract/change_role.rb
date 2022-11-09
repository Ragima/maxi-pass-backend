module User::Contract
  class ChangeRole < Reform::Form
    ALLOWED_ROLES = %w[admin support].freeze

    property :role_id

    validates :role_id, inclusion: { in: ALLOWED_ROLES}
  end
end
