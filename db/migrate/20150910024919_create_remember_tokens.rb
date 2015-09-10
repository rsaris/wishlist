class CreateRememberTokens < ActiveRecord::Migration
  def change
    create_table :remember_tokens do |t|
      t.integer :user_id
      t.string :remember_token
      t.datetime :last_used
      t.timestamps
    end

    add_index :remember_tokens, [:remember_token, :user_id]
  end
end