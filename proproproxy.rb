require 'webrick'
require 'webrick/httpproxy'
require 'yaml'


def escapeUrlElements(url)
	url = url.gsub '.', '\.'
	url = url.gsub '?', '\?'
	url = url.gsub '*', '.*'
end

file = YAML.load_file('map.yml')
rules = {}

# read all mappings first
for rule in file
	pattern = Regexp.new escapeUrlElements( rule["from"] )
	rules[pattern] = rule["to"]
end 

handler = proc do |req, res|
	
	rules.each do |pattern, to|

		result = pattern.match( res.request_uri.to_s )
		
		if !result.nil?
			res.header.delete("content-encoding")
			res.header.delete("content-length")
			res.body = File.read( to )
			puts "The resource at " + res.request_uri.to_s + " was replaced by the contents of " + to + "\n"
		end
	
		
	end
	
end

proxy = WEBrick::HTTPProxyServer.new Port: 8001, ProxyContentHandler: handler, Logger: WEBrick::Log.new("/dev/null"), AccessLog: [], ProxyVia: nil

trap 'INT'  do proxy.shutdown end
trap 'TERM' do proxy.shutdown end

proxy.start
