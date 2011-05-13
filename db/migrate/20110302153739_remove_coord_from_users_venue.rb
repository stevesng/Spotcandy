class RemoveCoordFromUsersVenue < ActiveRecord::Migration
  def self.up
    remove_column :users_venues, :lat
    remove_column :users_venues, :lng
  end

  def self.down
    add_column :users_venues, :lng, :decimal
    add_column :users_venues, :lat, :decimal
  end
end
