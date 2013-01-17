#!/usr/bin/env ruby
# coding: utf-8
require 'rubygems'
require 'rack'
require 'open-uri'
require 'json'
require 'uri'
require 'pp'

# iTunes Search API
# http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html

class SimpleApp

	def genReqURI2iTunes(req)
		country = req.params['country'] || 'JP'
		term = req.params['term'] || 'hatsunemiku'
		media = req.params['media']  || 'music'
		entity = req.params['entity'] || 'song'
		attribute = req.params['attribute'] || 'artistTerm'
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
		# GET REQUEST
		request = Rack::Request.new(env)

		# API Call
		uri = genReqURI2iTunes(request)
		doc = uri.read

		# Format contents
		## html5media.jsはfirefoxでのaudioタグ用
		res_js = "<script type='text/javascript' src='http://api.html5media.info/1.1.4/html5media.min.js'></script>"
		title = "iTunes Previewer"
		res_head = "<!DOCTYPE html><html lang='ja'><head><meta charset=utf-8><title>#{title}</title>#{res_js}</head><body>"
		res_body = "<h3>Search query: #{request.params['term']}</h3>URL: <a target='#blank' href=#{uri}>#{uri}</a><br>"

		resObj = JSON.parse(doc)
		count = resObj['resultCount']
		res_body << "Result count: #{count}<br>"

		is_first = true
		resObj['results'].each { |con|
			res_body << "<img src=#{con['artworkUrl100']}><br>"
			res_body << "Track: #{con['trackName']} <br> Artist: #{con['artistName']}<br>"
			res_body << "Genre: #{con['primaryGenreName']}"
			if is_first then
				res_body << "<audio controls autoplay>"
				is_first = false
			else
				res_body << "<audio controls >"
			end
			res_body << "<source src=#{con['previewUrl']} />"
			res_body << "<p>音声を再生するには、audioタグをサポートしたブラウザが必要です。</p>"
			res_body << "</audio><br>"
			
		}

		res_foot =  "</body></html>"

		# RESPONSE
		res_str = res_head + res_body + res_foot
		response = Rack::Response.new([res_str], 200, {'Content-Type' => 'text/html','charset' => 'shift_jis'})
		response["Content-Length"] = res_str.bytesize.to_s

		return response.finish
	end
end
run SimpleApp.new
