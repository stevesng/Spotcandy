class AddVenueTypeToUsersVenue < ActiveRecord::Migration
  def self.up
    add_column :users_venues, :venuetype, :int
  end

  def self.down
    remove_column :users_venues, :venuetype
  end
end
