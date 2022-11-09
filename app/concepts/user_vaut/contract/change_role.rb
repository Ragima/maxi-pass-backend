# frozen_string_literal: true

module UserVault::Contract
  class ChangeRole < Reform::Form

    property :vault_writer

    validates :vault_writer, inclusion: { in: [true, false] }
  end
end