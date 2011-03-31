module Burpdot
module Output

#
# This is a simple CSV output. Primarily to be consumed by Afterglow
#

class Csvout < BaseOutput
  
  def initialize(entries,options)
    super
  end
  
  def run
    
    @entries.each do |line|
      @oFile.syswrite(line['ref'].to_s + "," + line['host'].to_s + line['url'].to_s + "\n") if not line['ref'].nil? #write write write
    end
  end

end
end end