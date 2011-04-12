module Burpdot
  
class StatusChecker < WEBrick::HTTPServlet::AbstractServlet
   
  def db_exists(req,res)
    res.body = {'db_exists' => File.exists($root_dir + "/" + @config.get_value('burpdbfile')).to_s}
    raise WEBrick::HTTPStatus::OK
  end
  
  def do_GET(req,res)
    tmp #something about .to_s.match etc etc
    res.body = req.request_uri.to_s
    raise WEBrick::HTTPStatus::OK
  end
  
end

end