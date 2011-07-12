class AddCountryLatLongZipAndChangeLocationToPlacenameToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :country, :string
    add_column :articles, :latitude, :float
    add_column :articles, :longitude, :float
    add_column :articles, :zip, :integer
    rename_column :articles, :location, :placename
  end

  def self.down
    remove_column :articles, :placename
    rename_column :articles, :placename, :location
    remove_column :articles, :longitude
    remove_column :articles, :latitude
    remove_column :articles, :country
  end
end
