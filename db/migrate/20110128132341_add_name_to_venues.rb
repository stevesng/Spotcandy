class AddNameToVenues < ActiveRecord::Migration
  def self.up
    add_column :venues, :name, :string
  end

  def self.down
    remove_column :venues, :name
  end
end
