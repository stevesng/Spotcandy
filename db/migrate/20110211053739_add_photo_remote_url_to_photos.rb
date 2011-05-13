class AddPhotoRemoteUrlToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :photo_remote_url, :string
  end

  def self.down
    remove_column :photos, :photo_remote_url
  end
  
end
