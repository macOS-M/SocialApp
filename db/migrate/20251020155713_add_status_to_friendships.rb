class AddStatusToFriendships < ActiveRecord::Migration[8.0]
  def change
    add_column :friendships, :status, :string
  end
end
