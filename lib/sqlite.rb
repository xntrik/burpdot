require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'

require 'lib/model/weblog'

module Burpdot

class Sqlite

  def initialize(dbfile)
    DataMapper.setup(:default,"sqlite://#{dbfile}") #Specify the DB file
    DataMapper.finalize #Because we've specified the models already, above, we now finalize  
  end

end

end