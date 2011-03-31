module Burpdot
module Output
  
#
# All output classes should inherit this, as this Base class sets instance vars around output etc
#

class BaseOutput

  @entries = []
  @options = []
  @oFile = nil
  
  def initialize(entries, options)
    @entries = entries
    @options = options
    
    @oFile = File.new(@options['output'],'w') if not @options['output'].nil?
    @oFile = STDOUT if @oFile.nil?
    
  end
  
  def run()
  end
  
end

end end