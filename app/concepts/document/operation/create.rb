# frozen_string_literal: true

module Document::Operation
  class Create < Trailblazer::Operation

    step Model(Document, :new)
    step :create!
    step Contract::Build(constant: Document::Contract::Create)
    step Policy::Pundit(Document::Policy::DocumentPolicy, :create?)
    step Contract::Validate(key: :document)
    step Contract::Persist()
    success :encrypt_content!
    success :serialized_model!
    success :write_activity!
    success :remove_file!

    def create!(options, vault_item:, params:, **)
      options[:model] = vault_item.documents.new(file: params[:document][:file])
    end

    def serialized_model!(options, model:, current_user:, **)
      options[:serialized_model] = Document::Representer::Show.new(model).to_hash(user_options: { current_user: current_user })
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
        key: 'user.server_item.document.create',
        action_type: 'Document',
        action_act: 'Create',
        actor_action: 'created document',
        subj1_id: model.id,
        subj1_title: model.file.original_filename
      )
    end
  end
end
