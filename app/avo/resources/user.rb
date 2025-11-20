class Avo::Resources::User < Avo::BaseResource
  self.title = :id

  self.includes = [ :roles ]
  self.search = [ :id, :name, :email ]

  def fields
    field :id, as: :id
    field :email, as: :text

    field :name, as: :text, required: true

    field :role, as: :text do
      record.roles.pluck(:name).join(", ")
    end

    field :password, as: :password, required: true
    field :password_confirmation, as: :password, required: true
  end
end
