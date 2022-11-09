class ReportJob < ApplicationJob
  queue_as :report

  def perform(subject_id, user_id, current_user_id, subject_class)
    subject = subject_class.constantize.find_by(id: subject_id)
    current_user = User.find_by(id: current_user_id)
    user = User.find_by(id: user_id)
    return if [subject, user, current_user].include?(nil)

    report_file_location = "#{Rails.root}/tmp/#{subject.try(:name) || subject.try(:title)}_structure_report.pdf"
    subject_class.constantize.generate_report(subject, report_file_location)
    ReportingMailer.send(:structure_email, user.email, report_file_location, subject, current_user.email, nil).deliver_now
    File.delete(report_file_location) if File.exist?(report_file_location)
  end
end
