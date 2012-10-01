class AddUserStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_state, :boolean
  end
end
