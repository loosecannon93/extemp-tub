class CreateReadings < ActiveRecord::Migration
  def self.up
    create_table :readings do |t|
      t.integer :article_id
      t.integer :user_id
      t.integer :search_id

      t.timestamps
    end
  end

  def self.down
    drop_table :readings
  end
end
