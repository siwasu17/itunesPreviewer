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
	def call(env)
		country='JP'
		media='music'
		attribute='songTerm'
		limit=5

		# GET REQUEST
		request = Rack::Request.new(env)
		query = request.params['q']

		# リクエスト毎にAPI問い合わせ
		## NOTE: ネットにつながってないとつかえませんよ
		uri = URI.parse(
			"http://itunes.apple.com/search?"\
			"country=#{country}"\
			"&term=#{query}"\
			"&media=#{media}"\
			"&attribute=#{attribute}"\
			"&limit=#{limit}"
		)
		# API Call
		doc = uri.read

		# Format contents
		## html5media.jsはfirefoxでのaudioタグ用
		res_head = "<html><head><title>iTunes Previewer</title><script type='text/javascript' src='http://api.html5media.info/1.1.4/html5media.min.js'></script></head><body>"
		res_body = "<h3>Search query: #{query}</h3>URL: <a target='#blank' href=#{uri}>#{uri}</a><br>"

		resObj = JSON.parse(doc)
		count = resObj['resultCount']
		res_body << "Result count: #{count}<br>"

		resObj['results'].each { |con|
			res_body << "Track: #{con['trackName']} <br> Artist: #{con['artistName']}<br>"
			res_body << "<audio src=#{con['previewUrl']} controls>"
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

=begin
resObj = JSON.parse(doc)
count = resObj['resultCount']
puts "取得件数: #{count}"
resObj['results'].each { |con|
	puts "============"
	puts "TrackName: #{con['trackName']}"
	puts "Artist: #{con['artistName']}"
	puts "Preview: #{con['previewUrl']}"
}
=end
