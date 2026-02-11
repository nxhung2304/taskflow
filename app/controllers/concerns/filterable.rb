module Filterable
  extend ActiveSupport::Concern

  def collection_filter_by(collection, filters = {})
    return collection if filters.blank?

    filters.each do |key, value|
      method_name  = "with_#{key}"
      klass = controller_name.classify.constantize

      next unless value.present?
      next unless klass.respond_to?(method_name)

      if klass.defined_enums.key?(key)
        next unless klass.defined_enums[key].key?(value)
      end

      collection = collection.public_send(method_name, value)
    end

    collection
  end
end
