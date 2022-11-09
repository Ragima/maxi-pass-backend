# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :vault_item

  has_attached_file :file,
                    path: ':rails_root/public/system/:attachment/:id/:filename'
  do_not_validate_attachment_file_type :file
  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 1.megabytes

end
