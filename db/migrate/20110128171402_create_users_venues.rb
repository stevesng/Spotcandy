class CreateUsersVenues < ActiveRecord::Migration
  def self.up
    create_table :users_venues, {:id => false, :force => true} do |t|
      t.integer :venue_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users_venues
  end
end
