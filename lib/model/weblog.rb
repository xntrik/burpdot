module Burpdot
module Models
  
class Weblog
  include DataMapper::Resource
  
  storage_names[:default] = 'urls'
  
  property :id, Serial
  property :url, Text
  property :ref, Text
  
end

end end