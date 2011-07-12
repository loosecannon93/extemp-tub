class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :site
      t.string :title
      t.text :abstract
      t.text :full_text
      t.datetime :published
      t.string :url
      t.text :location

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
