class CreateCandiesUsers < ActiveRecord::Migration
  def self.up
    create_table :candies_users, {:id => false, :force => true} do |t|
      t.integer :candy_id
      t.integer :user_id
      t.integer :venue_id

      t.timestamps
    end
  end

  def self.down
    drop_table :candies_users
  end
end
