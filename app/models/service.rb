# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :team, foreign_key: 'team_name', optional: true
end
