class CreateCandies < ActiveRecord::Migration
  def self.up
    create_table :candies do |t|
      t.integer :venue_id
      t.string :pid
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :candies
  end
end
