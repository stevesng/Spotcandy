class AddDefaultPhotoToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :default_photo, :integer
  end

  def self.down
    remove_column :candies, :default_photo
  end
end
