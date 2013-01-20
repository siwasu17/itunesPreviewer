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
		resObj = JSON.parse(doc)

		count = resObj['resultCount']
		resBody = "<h3>Search query: #{request.params['term']}</h3>URL: <a target='#blank' href=#{uri}>#{uri}</a><br>"
		resBody << "Result count: #{count}<br>"

		trackNo = 0
		isFirst = true

		resBody << "<div id='slider' style='width:420px; height:200px'>"
		resObj['results'].each { |con|
			if isFirst then
				audioTagHead = "<audio id=a_#{trackNo} controls autoplay >"
				isFirst = false
			else
				audioTagHead = "<audio id=a_#{trackNo} controls autoplay >"
			end

			resBody << <<-"EOS"
				<div id=t_#{trackNo} >
					<div id=img_#{trackNo} style='float:left;'>
						<img src=#{con['artworkUrl100']}>
					</div>
					track: #{con['trackName']}<br>
					artist: #{con['artistName']}<br>
					genre: #{con['primaryGenreName']}
					#{audioTagHead}	
						<source src=#{con['previewUrl']} />
						<p>To play music, you need a browser that supports audio tag.</p>
					</audio>
					<div style='clear:both;'></div>
				</div>
			EOS

			trackNo = trackNo + 1	
		}
		resBody << "</div>"

		# Use template
		res_str = formatTemplate("index.html",
			{
				"__title__"=> "iTunesPreviewer",
				"__body__" => resBody,
			}
		)
		
		# Response
		response = Rack::Response.new([res_str], 200, {'Content-Type' => 'text/html','charset' => 'shift_jis'})
		response["Content-Length"] = res_str.bytesize.to_s

		return response.finish
	end
end

use Rack::Static, :urls => ["/js","/css"]
run SimpleApp.new
