module Burpdot
module Output

#
# This is a SQLite DB file output method. This creates a SQLite DB file, for further processing by
#  other burpdot tools
#

class Sqliteout < BaseOutput
  
  def initialize(entries,options)
    #We're not running super this time, because we want to override the normal behaviour of the 
    # @oFile instance var
    
    if options['output'].nil?
      puts "Please specify an output file with the -o option"
      exit
    end
    
    #Only now do we require this code
    require 'lib/sqlite'
    
    #Setup the object variables - note the oFile is NOT a normal file now
    @entries = entries
    @options = options
    @oFile = Dir.pwd + "/" + options['output'] #oFile is a SQLite ref, not a file to be opened now
    
    @sqlite = Burpdot::Sqlite.new(@oFile) #This sets up the database
    
    DataMapper.auto_migrate! #This clears the db file and creates the files.
    
  end
  
  def run
    @entries.each do |line|
      @dbentry = Burpdot::Models::Weblog.create( #This INSERTS new lines into the DB
        :url => line['host'].to_s + line['url'].to_s,
        :ref => line['ref'].to_s
      )
    end
  end
end

end
end