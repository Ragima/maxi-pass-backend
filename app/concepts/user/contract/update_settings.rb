# frozen_string_literal: true

module User::Contract
  class UpdateSettings < Reform::Form

    NAME_LENGTH_MAXIMUM = 100
    FIRST_NAME_LAST_NAME_LENGTH_MAXIMUM = 50
    NAME_REGEX = /\A[-a-zA-ZёЁа-яА-Я0-9'`"\s_]{1,#{NAME_LENGTH_MAXIMUM}}\z/.freeze
    FIRST_NAME_LAST_NAME_REGEX = /\A[-a-zA-ZёЁа-яА-Я0-9'`"\s_]{1,#{FIRST_NAME_LAST_NAME_LENGTH_MAXIMUM}}\z/.freeze
    NAME_MESSAGE = I18n.t('user.name.validation', name_length: NAME_LENGTH_MAXIMUM)
    FIRST_NAME_LAST_NAME_MESSAGE = I18n.t('user.name.validation', name_length: FIRST_NAME_LAST_NAME_LENGTH_MAXIMUM)

    property :first_name
    property :last_name
    property :name
    property :current_password, virtual: true
    property :password, virtual: true
    property :password_confirmation, virtual: true
    property :locale

    validates :first_name, :last_name,
              format: { with: FIRST_NAME_LAST_NAME_REGEX, message: FIRST_NAME_LAST_NAME_MESSAGE }

    validates :name,
              format: { with: NAME_REGEX, message: NAME_MESSAGE }

    validates :locale, presence: true, length: { maximum: 10 }
  end
end