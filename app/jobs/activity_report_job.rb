class ActivityReportJob < ApplicationJob
  queue_as :report

  def perform(user_id, current_user_id, subject_class, filters, subjects_ids)
    current_user = User.find_by(id: current_user_id)
    user = User.find_by(id: user_id)
    return if [subjects_ids, user, current_user].include?(nil)

    report_file_location = "#{Rails.root}/tmp/team_#{current_user.team.try(:name)}_activity_structure_report.pdf"
    subject_class.constantize.generate_report(report_file_location, filters, subjects_ids)
    ReportingMailer.send(:structure_email, user.email, report_file_location, current_user.team, current_user.email, filters).deliver_now
    File.delete(report_file_location) if File.exist?(report_file_location)
  end
end
