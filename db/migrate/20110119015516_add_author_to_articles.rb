class AddAuthorToArticles < ActiveRecord::Migration
  def self.up
   change_column :articles, :author, :string
  end

  def self.down
    remove_column :articles, :string
  end
end
