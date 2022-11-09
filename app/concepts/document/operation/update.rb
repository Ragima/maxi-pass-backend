# frozen_string_literal: true

module Document::Operation
  class Update < Trailblazer::Operation
    step Model(Document, :find_by, :id)
    step Policy::Pundit(Document::Policy::DocumentPolicy, :update?)
    step Contract::Build(constant: Document::Contract::Update)
    step Contract::Validate(key: :document)
    step Contract::Persist()
    success :encrypt_content!
    success :serialized_model!
    success :remove_file!
    success :write_activity!

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Document::Representer::Show.new(model).to_hash
    end

    def encrypt_content!(_options, model:, current_user:, vault_item:, **)
      encrypted_content = Encoder.new(current_user).update_encrypted_file(model, vault_item.vault)
      model.update_attributes(content: encrypted_content[:content], file_name: encrypted_content[:file_name]) if encrypted_content.present?
    end

    def remove_file!(_options, model:, **)
      model.file.destroy
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.server_item.document.update',
        action_type: 'Document',
        action_act: 'Update',
        actor_action: 'Update document',
        subj1_id: model.id,
        subj1_title: model.file.original_filename
      )
    end
  end
end




