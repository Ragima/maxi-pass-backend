# frozen_string_literal: true

require 'reform/form/validation/unique_validator'

module Group::Contract
  class Create < Reform::Form

    NAME_LENGTH_MAXIMUM = 50
    NAME_REGEX = /\A([a-zA-Zа-яА-Я0-9_\-\s()]{1,#{NAME_LENGTH_MAXIMUM}})\z/.freeze
    NAME_MESSAGE = I18n.t('group.name.validation', name_length: NAME_LENGTH_MAXIMUM)

    property :name
    property :team_name
    property :parent_group_id

    validates :name, presence: true,
                     unique: { case_sensitive: false, scope: :team_name },
                     format: { multiline: true, with: NAME_REGEX, message: NAME_MESSAGE }

    validates :team_name, presence: true
  end
end
