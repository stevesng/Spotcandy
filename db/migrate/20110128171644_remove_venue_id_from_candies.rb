class RemoveVenueIdFromCandies < ActiveRecord::Migration
  def self.up
    remove_column :candies, :venue_id
  end

  def self.down
    add_column :candies, :venue_id, :integer
  end
end
