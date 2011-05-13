class RemoveVenueIdFromCandiesUsers < ActiveRecord::Migration
  def self.up
    remove_column :candies_users, :venue_id
  end

  def self.down
    add_column :candies_users, :venue_id, :integer
  end
end
