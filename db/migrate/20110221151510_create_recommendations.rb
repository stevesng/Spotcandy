class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.integer :candy_id
      t.integer :user_id
      t.boolean :recommended, :null => false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
