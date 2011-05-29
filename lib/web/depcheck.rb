module Burpdot

  class Depcheck
    
    def checkafterglow
      return File.exists?("afterglow.pl")
    end
    
    def checkgraphviz
      gvexists = false
      ENV['PATH'].split(':').each do |folder|
        gvexists = true if File.exists?(folder+'/neato')
      end
      return gvexists
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
          if !checkgraphviz
            puts
            puts "You need to install Graphviz"
          end
          exit
        else
          if !checkgraphviz
            puts
            puts "You need to install Graphviz"
            exit
          end
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
        if !checkgraphviz
          puts
          puts "You need to install Graphviz"
        end
        exit
      end
    end
  end

end