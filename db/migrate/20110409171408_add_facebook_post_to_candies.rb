class AddFacebookPostToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :facebook_update, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :candies, :facebook_update
  end
end
