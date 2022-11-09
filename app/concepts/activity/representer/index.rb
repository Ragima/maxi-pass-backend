# frozen_string_literal: true

module Activity::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: Activity do
      property :id
      property :trackable_type
      property :trackable_id
      property :owner_type
      property :owner_id
      property :key
      property :parameters
      property :recipient_type
      property :recipient_id
      property :created_at
      property :updated_at
      property :team_name
      property :actor_role
      property :actor_email
      property :actor_action
      property :subj1_id
      property :subj1_title
      property :subj1_action
      property :subj2_id
      property :subj2_title
      property :subj2_action
      property :subj3_id
      property :subj3_title
      property :action_type
      property :action_act
    end
  end
end