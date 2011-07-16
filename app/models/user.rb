class User < ActiveRecord::Base
  acts_as_authentic
  #acts_as_tagger
  has_many :searches
  has_many :readings
  has_many :read_articles , :class_name => Article, :through => :readings
  
end 
