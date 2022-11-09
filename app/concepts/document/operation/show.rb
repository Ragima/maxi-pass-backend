# frozen_string_literal: true

module Document::Operation
  class Show < Trailblazer::Operation
    step :model!
    step Policy::Pundit(Document::Policy::DocumentPolicy, :show?)
    success :decrypted_file!
    success :write_activity!

    def model!(options, vault_item:, params:, **)
      options[:model] = model = vault_item.documents.find_by(id: params[:id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def encrypted?(_options, model:, **)
      model.encrypted
    end

    def decrypted_file!(options, model:, current_user:, **)
      options['model.response'] = Encoder.new(current_user).decrypted_file(model, model.vault_item.vault)
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.server_item.document.show',
        action_type: 'Document',
        action_act: 'Read',
        actor_action: 'Read document',
        subj1_id: model.id,
        subj1_title: model.file.original_filename
      )
    end
  end
end