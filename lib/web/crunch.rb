module Burpdot

class Crunch < WEBrick::HTTPServlet::AbstractServlet
  
  def do_GET(req,res)
    if req.request_uri.to_s =~ /csvtosvg\.json/i
      csvToSvg(req,res)
    elsif req.request_uri.to_s =~ /getsvg\.html/i
      getSvg(req,res)
    elsif
      res.body = "Missing data"
      raise WEBrick::HTTPStatus::OK
    end
  end
  
  def csvToSvg(req,res)
    csv = $config.get_value('burpdotcsv')
    svg = $config.get_value('burpsvg')
    `cat #{csv} | ./afterglow.pl -t -c burp.properties | neato -Tsvg -Gnormalize=true -Gsplines=true -Goverlap=vpsc -o #{svg}`
    res.body ="{\"svg_status\": \"success\"}"
    raise WEBrick::HTTPStatus::OK
  end
  
  def getSvg(req,res)
    file = File.open($root_dir + "/" + $config.get_value('burpsvg'),'r')
    res.body = file.read
    file.close
    raise WEBrick::HTTPStatus::OK
  end
  
end

end
