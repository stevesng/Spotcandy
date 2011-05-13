class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table :venues do |t|
      t.string :foursquare_id
      t.text :location
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :venues
  end
end
