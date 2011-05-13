class AddLockedCandyCountToVenues < ActiveRecord::Migration
  def self.up
    add_column :venues, :locked, :integer, :null => false, :default => 0
    add_column :venues, :candy_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :venues, :candy_count
    remove_column :venues, :locked
  end
end
