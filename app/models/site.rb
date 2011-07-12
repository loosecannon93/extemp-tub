class Site < ActiveRecord::Base
has_many :articles
def to_s
  self.name
end

end
