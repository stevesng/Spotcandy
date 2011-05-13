class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.integer :uid
      t.string :access_token
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :authentications
  end
end
