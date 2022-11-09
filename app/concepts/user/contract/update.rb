# frozen_string_literal: true

module User::Contract
  class Update < Reform::Form

    NAME_LENGTH_MAXIMUM = 100
    NAME_REGEX = /\A[-a-zA-ZёЁа-яА-Я0-9'`"\s_]{1,#{NAME_LENGTH_MAXIMUM}}\z/.freeze
    NAME_MESSAGE = I18n.t('user.name.validation', name_length: NAME_LENGTH_MAXIMUM)

    property :name

    validates :name,
              format: { with: NAME_REGEX, message: NAME_MESSAGE }

  end
end