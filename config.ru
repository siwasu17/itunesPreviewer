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
		country = req.params['country'] || 'JP'
		term = req.params['term'] || 'miku'
		media = req.params['media']  || 'music'
		entity = req.params['entity'] || 'song'
		attribute = req.params['attribute'] || 'songTerm'
		limit = req.params['limit'] || 5

		# リクエストURI生成
		URI.parse(
			"http://itunes.apple.com/search?"\
			"country=#{country}"\
			"&term=#{term}"\
			"&media=#{media}"\
			"&entity=#{entity}"\
			"&attribute=#{attribute}"\
			"&limit=#{limit}"
		)
	end

	def call(env)
		# Get request
		request = Rack::Request.new(env)

		if request.path_info == '/tunesapi' then
			uri = genReqURI2iTunes(request)
			json = uri.read

			# Response
			response = Rack::Response.new([json], 200, {'Content-Type' => 'application/json','charset' => 'utf-8'})
			response["Content-Length"] = json.bytesize.to_s
		else
			uri = genReqURI2iTunes(request)

			html = ""
			File.open("./index.erb"){|f|
				html = ERB.new(f.read).result(binding)
			}

			# Response
			response = Rack::Response.new([html], 200, {'Content-Type' => 'text/html','charset' => 'utf-8'})
			response["Content-Length"] = html.bytesize.to_s

		end

		return response.finish
	end
end

use Rack::Static, :urls => ["/js","/css"]
run SimpleApp.new
