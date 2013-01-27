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

			genre = { 
				2 => 'Alternative',
				3 => 'Anime',
				4 => 'Blues',
				5 => 'Brazillian',
				6 => 'Children\'s Music',
				7 => 'Chinese',
				8 => 'Christian & Gospel',
				9 => 'Classical',
				10 => 'Comedy',
				11 => 'Country',
				12 => 'Dance',
				13 => 'Disney',
				14 => 'Easy Listening',
				15 => 'Electronic',
				16 => 'Enka',
				17 => 'Fitness & Workout',
				18 => 'French Pop',
				19 => 'German Folk',
				20 => 'German Pop',
				21 => 'Hip Hop/Rap',
				22 => 'Holiday',
				23 => 'Indian',
				24 => 'Instrumental',
				25 => 'J-Pop',
				26 => 'Jazz',
				27 => 'K-Pop',
				28 => 'Karaoke',
				29 => 'Kayokyoku',
				30 => 'Korean',
				31 => 'Latin',
				32 => 'Kayokyoku',
				33 => 'Opera',
				34 => 'Pop',
				35 => 'R&B/Soul',
				36 => 'Reggae',
				37 => 'Rock',
				38 => 'Singer/Songwriter',
				39 => 'Soundtrack',
				40 => 'Spoken Word',
				41 => 'Vocal',
				42 => 'World'
			}

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
