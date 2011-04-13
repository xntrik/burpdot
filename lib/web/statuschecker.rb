module Burpdot
  
class StatusChecker < WEBrick::HTTPServlet::AbstractServlet

  def db_exists(req,res)
    config = Burpdot::Configuration.instance
    res.body = "{\"db_exists\": \"" + File::exists?($root_dir + "/" + config.get_value('burpdbfile')).to_s + "\"}"
    raise WEBrick::HTTPStatus::OK
  end
  
  def do_GET(req,res)
    if req.request_uri.to_s =~ /db_exists\.json/i
      db_exists(req,res)
    else
      res.body = "Missing data"
      raise WEBrick::HTTPStatus::OK
    end
  end
  
end

end
