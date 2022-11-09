# frozen_string_literal: true

class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  def role_user?
    role.eql? 'user'
  end

  def role_lead?
    role.eql? 'lead'
  end
end
