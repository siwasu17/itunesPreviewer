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


	# 簡易テンプレートエンジン
	def formatTemplate(tpl_file_name,val_hash)
		contents = ""
		File::open(tpl_file_name) {|f|
		  while line = f.gets
			val_hash.each {|k,v|
				# ハッシュに登録された変数を展開
				line.sub!(k,v)
			}
			contents << line
		  end
		}
		return contents
	end


	def call(env)
		# Get request
		request = Rack::Request.new(env)

		# API Call
		uri = genReqURI2iTunes(request)
		doc = uri.read

		# Generate contents body
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

		# Use template
		res_str = formatTemplate("index.html",
			{
				"__title__"=> "iTunesPreviewer",
				"__body__" => res_body
			}
		)
		
		# Response
		response = Rack::Response.new([res_str], 200, {'Content-Type' => 'text/html','charset' => 'shift_jis'})
		response["Content-Length"] = res_str.bytesize.to_s

		return response.finish
	end
end
run SimpleApp.new
