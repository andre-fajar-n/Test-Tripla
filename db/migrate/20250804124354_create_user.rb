class CreateUser < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.datetime "created_at", null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.string "name", null: false
    end
  end
end
