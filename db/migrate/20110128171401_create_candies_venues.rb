class CreateCandiesVenues < ActiveRecord::Migration
  def self.up
    create_table :candies_venues, {:id => false, :force => true} do |t|
      t.integer :venue_id
      t.integer :candy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :candies_venues
  end
end
