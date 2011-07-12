class AddDocIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :docid, :integer
  end

  def self.down
    remove_column :articles, :docid
  end
end
