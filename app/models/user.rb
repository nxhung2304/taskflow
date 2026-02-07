# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string           not null
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  rolify

  devise :database_authenticatable, :registerable, :validatable

  has_many :boards, dependent: :destroy
  has_many :assigned_tasks,
         class_name: "Task",
         foreign_key: :assignee_id,
         dependent: :nullify
  has_many :comments, dependent: :destroy

  validates :name, presence: true

  def confirmed_at
    DateTime.now
  end

  def admin?
    has_role?(:admin)
  end
end
