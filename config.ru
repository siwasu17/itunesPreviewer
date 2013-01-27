#!/usr/bin/env ruby
# coding: utf-8
require 'rubygems'
require 'rack'
require 'open-uri'
require 'json'
require 'uri'
require 'pp'
require 'erb'

# iTunes Search API
# http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html

class SimpleApp

	def genReqURI2iTunes(req)
		# リクエストURI生成
		URI.parse(
			"http://itunes.apple.com/search?"\
			"country=#{req.params['country']}"\
			"&term=#{req.params['term']}"\
			"&media=#{req.params['media']}"\
			"&entity=#{req.params['entity']}"\
			"&attribute=#{req.params['attribute']}"\
			"&limit=#{req.params['limit']}"\
			"&offset=#{req.params['offset']}"
		)
	end

	def call(env)
		# Get request
		request = Rack::Request.new(env)

		uri = genReqURI2iTunes(request)

		if request.path_info == '/tunesapi' then
			contents = uri.read

			response = Rack::Response.new([contents], 200, {'Content-Type' => 'application/json','charset' => 'utf-8'})
		else
			contents = ""
			File.open("./index.erb"){|f|
				contents = ERB.new(f.read).result(binding)
			}

			response = Rack::Response.new([contents], 200, {'Content-Type' => 'text/html','charset' => 'utf-8'})
		end

		response["Content-Length"] = contents.bytesize.to_s
		return response.finish
	end
end

use Rack::Static, :urls => ["/js","/css", "/img"]
run SimpleApp.new
