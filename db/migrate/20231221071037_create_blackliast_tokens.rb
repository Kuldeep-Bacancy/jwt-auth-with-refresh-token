class CreateBlackliastTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :blackliast_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
