class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :user_id
      t.string :steam_id
      t.string :name

      t.timestamps
    end
  end
end
