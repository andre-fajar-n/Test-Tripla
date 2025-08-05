class CreateOtherTables < ActiveRecord::Migration[7.2]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :sleep_at, null: false
      t.datetime :wake_at

      t.timestamps
    end

    add_index :sleep_records, :sleep_at
    add_index :sleep_records, :wake_at

    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :follows, [ :follower_id, :followed_id ], unique: true
  end
end
