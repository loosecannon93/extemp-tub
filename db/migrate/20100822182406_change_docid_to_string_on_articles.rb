class ChangeDocidToStringOnArticles < ActiveRecord::Migration
  def self.up
    change_column :articles, :docid, :string
  end

  def self.down
    raise  ActiveRecord::IrreversibleMigration
  end
end
