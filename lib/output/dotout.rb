module Burpdot
module Output

#
#This is a simple direct gv output method.
#The preferred method is to use CSV and then use Afterglow
#

class Dotout < BaseOutput
  
  def initialize(entries,options)
    super
  end
  
  def run
    
    @oFile.syswrite("digraph Burp {\nnode [shape=rect]\n") #The gv file header
    
    @entries.each do |line|
      @oFile.syswrite("\"" + line['ref'].to_s + "\"->") if not line['ref'].nil? #Is there a ref? Write it out
      @oFile.syswrite("\"" + line['host'].to_s + line['url'].to_s + "\"\n") #Write out the URL
    end
    
    @oFile.syswrite("\noverlap=" + @options['overlap'] + "\n}\n") #Close out the gv file
  end

end
end end