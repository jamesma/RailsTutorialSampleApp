class AddEmailConfirmToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_confirm_token, :string
  end
end
