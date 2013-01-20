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
		resObj = JSON.parse(doc)

		count = resObj['resultCount']
		res_body = "<h3>Search query: #{request.params['term']}</h3>URL: <a target='#blank' href=#{uri}>#{uri}</a><br>"
		res_body << "Result count: #{count}<br>"

		trackNo = 1

		res_body << "<div id='slider' style='width:420px; height:200px'>"
		resObj['results'].each { |con|
			res_body << <<-"EOS"
				<div id=t_#{trackNo} >
					<img src=#{con['artworkUrl100']}>
					<audio id=a_#{trackNo} controls autoplay>
					<source src=#{con['previewUrl']} />
					<p>音声を再生するには、audioタグをサポートしたブラウザが必要です。</p>
					</audio>
					Track: #{con['trackName']}<br>
					Artist: #{con['artistName']}<br>
					Genre: #{con['primaryGenreName']}
				</div>
			EOS

			trackNo = trackNo + 1	
		}
		res_body << "</div>"

		# Use template
		res_str = formatTemplate("index.html",
			{
				"__title__"=> "iTunesPreviewer",
				"__body__" => res_body,
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
