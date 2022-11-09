# frozen_string_literal: true

module Vault::Contract
  class Create < Reform::Form
    TITLE_LENGTH_MAXIMUM = 50
    DESCRIPTION_LENGTH_MAXIMUM = 70
    TITLE_REGEX = /\A[-a-zA-Z0-9а-яА-Я\s_()]{1,#{TITLE_LENGTH_MAXIMUM}}\z/.freeze
    TITLE_MESSAGE = I18n.t('vault.title.validation', title_length: TITLE_LENGTH_MAXIMUM)
    DESCRIPTION_REGEX = /\A([a-zA-Z0-9а-яА-Я\s\-_()]{0,#{DESCRIPTION_LENGTH_MAXIMUM}})\z/.freeze
    DESCRIPTION_MESSAGE = I18n.t('vault.description.validation', description_length: DESCRIPTION_LENGTH_MAXIMUM)

    property :title
    property :description

    validates :title, format: { multiline: true, with: TITLE_REGEX, message: TITLE_MESSAGE }


    validates :description, allow_nil: true,
                            format: { multiline: true, with: DESCRIPTION_REGEX, message: DESCRIPTION_MESSAGE }

  end
end