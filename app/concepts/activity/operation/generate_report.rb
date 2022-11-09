# frozen_string_literal: true

module Activity::Operation
  class GenerateReport < Trailblazer::Operation
    step Policy::Pundit(ActivityPolicy, :generate_report?)
    step :model!
    success :create_report!

    def model!(options, params:, current_user:, **)
      options[:model] = Activity.with_pagination(nil, Activity.count, params, current_user)
    end

    def create_report!(options, model:, current_user:, params:, **)
      options['model.response'] = :no_content
      ActivityReportJob.perform_later(params[:user_id], current_user.id, 'Activity', filters(params), model.pluck(:id))
    end

    private

    def filters(params)
      { activity_type: params[:activity_type],
        action_type: params[:action_type],
        action_act: params[:action_act],
        from: params[:from],
        to: params[:to],
        actor: params[:actor] }
    end
  end
end
