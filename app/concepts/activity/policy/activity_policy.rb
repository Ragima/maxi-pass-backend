# frozen_string_literal: true

class ActivityPolicy
  attr_reader :model, :user

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    @user.admin?
  end

  def generate_report?
    @user.admin?
  end
end
