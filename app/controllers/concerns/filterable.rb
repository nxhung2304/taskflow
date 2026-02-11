module Filterable
  extend ActiveSupport::Concern

  def collection_filter_by(collection, filters = {})
    return collection if filters.blank?

    filters.each do |key, value|
      begin
        klass = controller_name.classify.constantize

        next unless klass.respond_to?("with_#{key}")

        collection = collection.public_send("with_#{key}", value) if value.present?
      rescue ArgumentError
        next
      end
    end

    collection
  end
end
