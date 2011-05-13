class AddVenueTypeToUsersVenues < ActiveRecord::Migration
  def self.up
    add_column :users_venues, :venue_type, :string
  end

  def self.down
    remove_column :users_venues, :venue_type
  end
end
