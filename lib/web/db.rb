module Burpdot

class Db < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(req,res)
    require 'lib/sqlite'
    @config = Burpdot::Configuration.instance
    @sqlite = Burpdot::Sqlite.new($root_dir + "/" + @config.get_value('burpdbfile'))
    @db = Burpdot::Models::Weblog
    
    if req.request_uri.to_s =~ /count\.json/i
      dbCount(req,res)
    else
      res.body = "Missing data"
      raise WEBrick::HTTPStatus::OK
    end
    
  end
  
  def dbCount(req,res)
    res.body = "{\"db_record_count\": " + @db.count.to_s + "}"
    raise WEBrick::HTTPStatus::OK
  end
  
  def prettyDb(req,res)
    require 'builder'
    
    
  end
end

end