class AddDeviseTokenAuthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider, :string, null: false, default: "email"
    add_column :users, :uid, :string, null: false, default: ""

    add_column :users, :allow_password_change, :boolean, default: false
    add_column :users, :tokens, :json

    add_column :users, :image, :string
  end
end
