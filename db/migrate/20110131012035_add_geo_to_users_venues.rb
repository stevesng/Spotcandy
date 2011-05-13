class AddGeoToUsersVenues < ActiveRecord::Migration
  def self.up
    add_column :users_venues, :lat, :decimal, :precision => 15, :scale => 10
    add_column :users_venues, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :users_venues, :lng
    remove_column :users_venues, :lat
  end
end
