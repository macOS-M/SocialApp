class AddConstraintsToMessages < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    say_with_time "Backfilling messages.read = false for existing rows" do
      # Use direct model access; Rails loads app models for migrations in standard setups.
      Message.reset_column_information
      Message.where(read: nil).update_all(read: false)
    end

    # Set default and enforce NOT NULL for read
    change_column_default :messages, :read, from: nil, to: false
    change_column_null :messages, :read, false, false

    # Add indexes for sender_id and recipient_id (concurrently because ddl transaction is disabled)
    unless index_exists?(:messages, :sender_id)
      add_index :messages, :sender_id, algorithm: :concurrently
    end

    unless index_exists?(:messages, :recipient_id)
      add_index :messages, :recipient_id, algorithm: :concurrently
    end

    # Ensure there are no NULLs before adding FK constraints
    if Message.where(sender_id: nil).exists?
      raise ActiveRecord::IrreversibleMigration, "Cannot add foreign key for sender_id: NULL values exist in messages"
    end

    if Message.where(recipient_id: nil).exists?
      raise ActiveRecord::IrreversibleMigration, "Cannot add foreign key for recipient_id: NULL values exist in messages"
    end

    # Add foreign keys to users table
    add_foreign_key :messages, :users, column: :sender_id, on_delete: :cascade
    add_foreign_key :messages, :users, column: :recipient_id, on_delete: :cascade

    # Enforce NOT NULL for sender_id and recipient_id
    change_column_null :messages, :sender_id, false
    change_column_null :messages, :recipient_id, false
  end

  def down
    # remove NOT NULL constraints
    change_column_null :messages, :recipient_id, true
    change_column_null :messages, :sender_id, true

    # remove foreign keys
    remove_foreign_key :messages, column: :recipient_id
    remove_foreign_key :messages, column: :sender_id

    # remove indexes if they exist
    if index_exists?(:messages, :recipient_id)
      remove_index :messages, column: :recipient_id, algorithm: :concurrently
    end

    if index_exists?(:messages, :sender_id)
      remove_index :messages, column: :sender_id, algorithm: :concurrently
    end

    # revert default and nullability for read
    change_column_default :messages, :read, from: false, to: nil
    change_column_null :messages, :read, true
  end
end
