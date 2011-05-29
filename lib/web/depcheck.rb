module Burpdot

  class Depcheck
    
    def checkdeps
      @gems_required = ["parseconfig","dm-core","dm-migrations","dm-aggregates","dm-sqlite-adapter","builder"]
      @gems_missing = Array.new
      
      @gems_required.each do |current_gem|
        begin
          gem current_gem
        rescue Gem::LoadError
          @gems_missing << current_gem
        end
      end
      
      if @gems_missing.length == 0 
        #No missing gems
        return true
      else
        #You're missing gems
        puts "You're missing some gems, make sure you install the following gems:"
        @gems_missing.each do |current_gem|
          puts current_gem
        end
        exit
      end
    end
  end

end