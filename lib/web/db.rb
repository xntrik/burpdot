require 'pp'
module Burpdot

class Db < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(req,res)
    require 'lib/sqlite'
    @config = Burpdot::Configuration.instance
    @sqlite = Burpdot::Sqlite.new($root_dir + "/" + @config.get_value('burpdbfile'))
    @db = Burpdot::Models::Weblog
    
    if req.request_uri.to_s =~ /count\.json/i
      dbCount(req,res)
    elsif req.request_uri.to_s =~ /prettyul\.html/i
      prettyDb(req,res)
    elsif req.request_uri.to_s =~ /prettyullite\.html/i
      prettyDbLite(req,res)
    elsif req.request_uri.to_s =~ /dbdumptocsv/i
      dbDumptoCsv(req,res)
    else
      res.body = "Missing data"
      raise WEBrick::HTTPStatus::OK
    end
    
  end

  alias :do_POST :do_GET
  
  # /db/dbdumptocsv
  # needs a 'select' parameter, a comma separated list of URLs to query for
  def dbDumptoCsv(req,res)
    qs = req.query["select"].split(",")
    @dbout = []
    qs.each do |q|
      @dbout = @dbout + @db.all(:url => q)
    end
    
    # Open the output csv file
    @oFile = File.new("#{$root_dir}/" + @config.get_value('burpdotcsv'), 'w')
    
    @dbout.each do |entry|
      @oFile.syswrite(entry.ref + "," + entry.url + "\n") if entry.ref.length > 0
    end
    
    @oFile.close
  end
  
  # /db/count.json - return the number of records in the DB
  def dbCount(req,res)
    res.body = "{\"db_record_count\": " + @db.count.to_s + "}"
    raise WEBrick::HTTPStatus::OK
  end
  
  # Really similar to prettyDb, except, the tree is lighter, and only printing "Valid" entry records *phew*
  def prettyDbLite(req,res)
    require 'builder'
    urlArray = []
    @db.all.each do |entry|
      urlArray << entry.url
    end
    
    urlArray.uniq!
    
    parentHash = Hash.new {|h,k| h[k] = []}
    
    urlArray.each do |path|
      tmpPath = path.split("/",2)
      if tmpPath[1].length == 0 #Therefore this is a domain with no paths under it
        parentHash[tmpPath[0]] << "/"
      else #Therefore there are sub-folders
        parentHash[tmpPath[0]] << "/" + tmpPath[1]
      end
    end
    
    xml = Builder::XmlMarkup.new(:indent=>2)
    
    xml.ul do
      parentHash.each_key do |url|
        xml.li do
          xml.a(url, "href"=>"#")
          xml.ul do
            parentHash[url].each do |fold|
              xml.li(:id => url + fold) do
                xml.a(fold, "href"=>"#")
              end
            end
          end
        end
      end
    end
    
    res.body = xml.to_s
    raise WEBrick::HTTPStatus::OK

  end
      
  # /db/prettyul.html - return an UL of all the URLs
  def prettyDb(req,res)
    require 'builder'
    urlArray = []
    @db.all.each do |entry|
      urlArray << entry.url
    end
    
    auto_hash = Hash.new { |h,k| h[k] = Hash.new &h.default_proc }
    
    urlArray.each do |path|
      sub = auto_hash
      pp sub if sub.length == 1
      pp auto_hash if auto_hash.length == 1
      path.split("/").each{ |dir| sub[dir]; sub = sub[dir] }
    end
   
    @somecounter = 1
 
    def build_branch(branch,xml)
      directories = branch.keys.reject{|k| branch[k].empty?}.sort
      leaves = branch.keys.select{|k| branch[k].empty?}.sort
      
      directories.each do |directory|
        xml.li(:id => "phtml_"+@somecounter.to_s) do
          xml.a(directory, "href"=>"#")
          @somecounter = @somecounter + 1
          xml.ul do
            build_branch(branch[directory], xml)
          end
	      end
      end
      
      leaves.each do |leaf|
        xml.li(:id => "phtml_"+@somecounter.to_s) do
          xml.a(leaf, "href"=>"#")
        end
        @somecounter = @somecounter + 1
      end
    end
    
    xml = Builder::XmlMarkup.new(:indent => 2)
    
    xml.ul do
      build_branch(auto_hash, xml)
    end
    
    res.body = xml.to_s
    raise WEBrick::HTTPStatus::OK
  end
end

end
