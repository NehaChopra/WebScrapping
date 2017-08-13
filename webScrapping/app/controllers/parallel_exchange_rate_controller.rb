class ParallelExchangeRateController < ApplicationController

	require 'openssl'
	require 'open-uri'

	def exchange_rate
		web_doc = Nokogiri::HTML(open("https://www.abokifx.com/", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))

		# parsing an html and fetching the webpage information in web_doc object
		#:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE to avoid certification matching
		rates_table = web_doc.css(".home-section .lagos-market-rates-inner .grid-table")
		#web_doc.css is CSS selector
		rates_heading = rates_table.css("thead tr th .currency-title")

		# fetch the regions mentioned
		region_hash = {}
		rates_heading.each do |heads|
			region_hash[heads.text.strip] = Array.new
		end

		rates_body_table = rates_table.css("tr.table-line .table-col")

		# fetch the rates and date specified under the regions
		rates_array =
		rates_body_table.map do |body|
			body.text
		end

		hash_keys = region_hash.keys
		index = -1
		hash_index = -1
		while(index < rates_array.length - 1)
			hash_index = -1 if(hash_index.eql?(hash_keys.length - 1))

			region_hash[hash_keys[hash_index = hash_index + 1]] << rates_array[index = index + 1]
		end

		@formatted_hash = region_hash
		@rates_array_final = rates_array
		# these objects will be used in the view
		render template: 'parallel_exchange_rate/home'
	end

end
