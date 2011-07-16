class Search < ActiveRecord::Base
  belongs_to :user
  has_many :readings
  #named_scope :last , lambda {|n,user| {:conditions => "user_id = #{user.id}", :order => 'created_at DESC', :limit => n}}
  scope :last_n , lambda {|n| {:order => 'created_at DESC', :limit => n}}
end
