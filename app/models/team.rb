# frozen_string_literal: true

class Team < ApplicationRecord
  include PublicActivity::Common

  has_many :users, foreign_key: :team_name, dependent: :destroy
  has_many :vaults, foreign_key: :team_name, dependent: :destroy
  has_many :groups, foreign_key: :team_name, dependent: :destroy
  has_many :services, foreign_key: :team_name, dependent: :destroy
  has_many :activities, foreign_key: :team_name, dependent: :destroy

  NAME_LENGTH_MAXIMUM = 50
  NAME_REGEX = /([a-zA-Z0-9_\-]{1,#{NAME_LENGTH_MAXIMUM}})/.freeze
  NAME_REGEX_VALIDATE = /\A(\d|\w|_){1,#{NAME_LENGTH_MAXIMUM}}$\z/.freeze
  NAME_MESSAGE = I18n.t('user.name.validation')

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { multiline: true, with: NAME_REGEX, message: NAME_REGEX_VALIDATE },
                   length: { maximum: NAME_LENGTH_MAXIMUM }

end
