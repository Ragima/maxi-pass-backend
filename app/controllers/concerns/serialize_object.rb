module SerializeObject
  extend ActiveSupport::Concern

  def serialized_object(object)
    object.class.name.concat('Serializer').constantize.new(object).serialized_json
  end
end
