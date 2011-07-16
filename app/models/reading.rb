class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  belongs_to :search
  scope :last_n , lambda {|n| {:order => 'created_at DESC', 
    :limit => n}}
end
