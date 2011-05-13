class AddVenueIdToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :venue_id, :integer
  end

  def self.down
    remove_column :candies, :venue_id
  end
end
