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
    else
      res.body = "Missing data"
      raise WEBrick::HTTPStatus::OK
    end
    
  end
  
  # /db/count.json - return the number of records in the DB
  def dbCount(req,res)
    res.body = "{\"db_record_count\": " + @db.count.to_s + "}"
    raise WEBrick::HTTPStatus::OK
  end
  
  # /db/prettyul.html - return an UL of all the URLs
  def prettyDb(req,res)
    require 'builder'
    urlArray = []
    @db.all.each do |entry|
      urlArray << entry.url.to_s
    end
    
    auto_hash = Hash.new { |h,k| h[k] = Hash.new &h.default_proc }
    
    urlArray.each do |path|
      sub = auto_hash
      path.split("/").each{ |dir| sub[dir]; sub = sub[dir] }
    end
    
    def build_branch(branch,xml)
      directories = branch.keys.reject{|k| branch[k].empty?}.sort
      leaves = branch.keys.select{|k| branch[k].empty?}.sort
      
      directories.each do |directory|
        xml.li(:class => 'folder') << "<a href=\"#\">" + directory + "</a>\n"
        xml.ul do
          build_branch(branch[directory], xml)
        end
      end
      
      leaves.each do |leaf|
        xml.li(:class => 'leaf') << "<a href=\"#\">" + leaf + "</a>\n"
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