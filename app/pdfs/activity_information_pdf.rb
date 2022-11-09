class ActivityInformationPdf < Prawn::Document
  def initialize(activities, params)
    super(top_margin: 70)
    @params = params
    @activities = activities
    font(Rails.root.join("public/fonts/OpenSans-Regular.ttf")) do
      table activities_table, header: true
    end
  end

  def activities_table
    text filters
    table_header + @activities.map{ |activity| [ name(activity), type(activity), action(activity), date(activity), actor(activity) ] }
  end

  private

  def filters
    "Filters: #{activity_type_params} #{action_act_params} #{from_params} #{to_params} #{actor_params}"
  end

  def table_header
    [%w(Activity Type Action Date Actor)]
  end

  def activity_type_params
    "activity_type - #{@params[:activity_type]}" if @params[:activity_type]
  end

  def action_act_params
    "action - #{@params[:action_act]}" if @params[:action_act]
  end

  def actor_params
    "actor - #{@params[:actor]}" if @params[:actor]
  end

  def from_params
    "from_date - #{@params[:from].try(:to_date).try(:strftime, "%Y/%m/%d %H:%M")}" if @params[:from]
  end

  def to_params
    "to_date - #{@params[:to].try(:to_date).try(:strftime, "%Y/%m/%d %H:%M")}" if @params[:to]
  end

  def name(activity)
    "#{activity.try(:actor_email)} #{activity.try(:actor_action)}
     #{activity.try(:subj1_title)} #{activity.try(:subj1_action)}
     #{activity.try(:subj2_title)} #{activity.try(:subj2_action)}
     #{activity.try(:subj3_title)} #{activity.try(:subj3_action)}"
  end

  def type(activity)
    "#{activity.try(:action_type)}"
  end

  def action(activity)
    "#{activity.try(:action_act)}"
  end

  def date(activity)
    "#{activity.try(:created_at).try(:strftime, "%Y/%m/%d %H:%M")}"
  end

  def actor(activity)
    "#{activity.try(:actor_email)}"
  end
end
