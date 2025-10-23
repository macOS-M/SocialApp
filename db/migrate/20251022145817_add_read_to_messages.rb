class AddReadToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :read, :boolean
  end
end
