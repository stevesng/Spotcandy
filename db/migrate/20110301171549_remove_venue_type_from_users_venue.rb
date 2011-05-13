class RemoveVenueTypeFromUsersVenue < ActiveRecord::Migration
  def self.up
    remove_column :users_venues, :venue_type
  end

  def self.down
    add_column :users_venues, :venue_type, :string
  end
end
