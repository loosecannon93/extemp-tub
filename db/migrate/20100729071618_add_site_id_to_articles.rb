class AddSiteIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :site_id, :integer
  end

  def self.down
    remove_column :articles, :site_id
  end
end
