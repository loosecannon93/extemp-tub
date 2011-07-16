class Article < ActiveRecord::Base
belongs_to :site
has_many :readings
has_many :readers, :class_name => User, :through => :readings

validates_uniqueness_of :docid
  cattr_reader :per_page
  @@per_page = 10
  acts_as_taggable
  acts_as_taggable_on :locations,  :topics

  #scope :popular , lambda {|n|}

  define_index do
    # fields
    indexes title, :sortable => true
    indexes sub_title
    indexes abstract
    indexes full_text
    indexes url
    indexes corrections
    indexes placename, :sortable => true
    
   # indexes locations.name, :as => :locations
   # indexes topics.name, :as => :topics
    indexes tags.name, :as => :tags
    
    # attributes
    has site_id, created_at, updated_at, published, zip, latitude, longitude, country

#    set_property :delta => true
  end
end
  
