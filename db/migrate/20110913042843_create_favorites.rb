class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :venuetype
      t.boolean :watched
      t.references :user
      t.references :venue
      t.timestamps
    end
  end

  def self.down
    drop_table :favorites
  end
end
