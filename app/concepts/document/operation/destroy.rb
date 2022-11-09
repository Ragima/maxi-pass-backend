# frozen_string_literal: true

module Document::Operation
  class Destroy < Trailblazer::Operation
    step :model!
    step Policy::Pundit(Document::Policy::DocumentPolicy, :destroy?)
    step :destroy!
    success :write_activity!

    def model!(options, vault_item:, params:, **)
      options[:model] = model = vault_item.documents.find_by(id: params[:id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def destroy!(options, model:, **)
      options['model.response'] = :no_content
      model.destroy
      result = Result.new(!model.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.server_item.document.destroy',
        action_type: 'Document',
        action_act: 'Delete',
        actor_action: 'Deleted document',
        subj1_id: model.id,
        subj1_title: model.file.original_filename
      )
    end
  end
end