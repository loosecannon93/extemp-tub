class AddSubtitleToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :sub_title, :string
  end

  def self.down
    remove_column :articles, :sub_title
  end
end
