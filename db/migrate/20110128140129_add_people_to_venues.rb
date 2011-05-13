class AddPeopleToVenues < ActiveRecord::Migration
  def self.up
    add_column :venues, :people_count, :int
  end

  def self.down
    remove_column :venues, :people_count
  end
end
