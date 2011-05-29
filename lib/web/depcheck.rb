module Burpdot

  class Depcheck
    
    def checkafterglow
      if File.exists?("afterglow.pl")
        return true
      else
        return false
      end
    end
    
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
        if !checkafterglow
          puts "You're missing Afterglow - please download Afterglow from http://afterglow.sourceforge.net/ and put afterglow.pl in Burpdot's folder"
          puts "Ensure you've installed Perl's Text::CSV module too! (try: cpan Text::CSV)"
          exit
        end
      else
        #You're missing gems
        puts "You're missing some gems, make sure you install the following gems:"
        @gems_missing.each do |current_gem|
          puts current_gem
        end
        if !checkafterglow
          puts "You're missing Afterglow - please download Afterglow from http://afterglow.sourceforge.net/ and put afterglow.pl in Burpdot's folder"
          puts "Ensure you've installed Perl's Text::CSV module too! (try: cpan Text::CSV)"
        end
        exit
      end
    end
  end

end