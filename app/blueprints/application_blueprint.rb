class ApplicationBlueprint < Blueprinter::Base
  identifier :id

  field :created_at do |obj|
    obj.created_at&.iso8601
  end

  field :updated_at do |obj|
    obj.updated_at&.iso8601
  end
end
