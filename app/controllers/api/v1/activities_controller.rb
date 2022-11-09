# frozen_string_literal: true

module Api::V1
  class ActivitiesController < ApplicationController

    def index
      endpoint operation: Activity::Operation::Index,
               options: { current_user: current_user }
    end

    def generate_report
      endpoint operation: Activity::Operation::GenerateReport,
               options: { current_user: current_user }
    end
  end
end
