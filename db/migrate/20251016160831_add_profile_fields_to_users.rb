class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :name, :string, null: false
    add_column :users, :bio, :text
    add_column :users, :profile_picture, :string
    add_column :users, :cover_photo, :string
    add_column :users, :date_of_birth, :date, null: false
    add_column :users, :location, :string

    add_index :users, :username, unique: true
  end
end
