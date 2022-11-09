# frozen_string_literal: true

class Activity < PublicActivity::Activity
  scope :like, ->(field, parameter) { where("#{field} ILIKE ?", "%#{parameter}%") unless parameter.blank? }
  scope :range, ->(field, condition, parameter) { where("#{field} #{condition} ?", parameter) unless parameter.blank? }
  scope :compare, ->(field, parameter) { where("#{field} = ?", parameter) unless parameter.blank? }

  def self.with_pagination(page, per_page, params, current_user)
    initial_scope = like('action_act', params[:action_act])
                    .like('actor_email', params[:actor])
                    .like('action_type', params[:action_type])
                    .range('created_at', '>=', params[:from])
                    .range('created_at', '<=', params[:to])
    unless params[:activity_type].blank?
      query = "%#{params[:activity_type]}%"
      initial_scope = initial_scope
                      .where('actor_email ILIKE ? OR actor_action ILIKE ? OR subj1_title ILIKE ? OR subj2_title ILIKE ? OR subj3_title ILIKE ?',
                             query, query, query, query, query)
    end
    initial_scope
      .where(team_name: current_user.team_name)
      .order(created_at: :desc)
      .page(page)
      .per(per_page)
  end

  def self.generate_report(report_file_location, filters, activities_ids)
    activities = Activity.where(id: activities_ids).order(created_at: :desc)
    pdf = ActivityInformationPdf.new(activities, filters)
    pdf.render_file File.join(report_file_location)
  end
end
