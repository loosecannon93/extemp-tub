class AddCorrectionsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :corrections, :text
  end

  def self.down
    remove_column :articles, :corrections
  end
end
