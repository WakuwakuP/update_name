# coding: utf-8
require 'rubygems'
require 'twitter'
require 'yaml'

tokens = YAML.load_file("./key.yml")
tokens.each do |token|
	@client = Twitter::REST::Client.new(token)
	@stream_client = Twitter::Streaming::Client.new(token)
end

def ng_word?(name)
    ng_words = YAML.load_file("ng_word.yml")
    if ng_words.kind_of?(Array)
        ng_words.map do |ng_word|
            true if name.include?(ng_word)
        end.include?(true)
    else
        false
    end
end


@stream_client.user do |status|
	next unless status.is_a? Twitter::Tweet
	next if status.text.start_with? "RT"
	if status.text =~ /@waku_P\supdate_name\s.+?$/ then
		name = status.text.gsub("@waku_P\supdate_name\s","")
		next if name.length > 20
		next if ng_word?(name)
		@client.update_profile(:name => name)
		option = {"in_reply_to_status_id" => status.id.to_s}
		tweet = ".@#{status.user.screen_name} により#{name}に変更しました。"
		@client.update tweet,option
	elsif status.text =~ /.+?\(@waku_P\)/ then
		name = status.text.gsub("(@waku_P)","")
		next if name.length > 20
		next if ng_word?(name)
		@client.update_profile(:name => name)
		option = {"in_reply_to_status_id" => status.id.to_s}
		tweet = ".@#{status.user.screen_name} により#{name}に変更しました。"
			@client.update tweet,option
	elsif status.text =~ /@waku_P\supdate_location\s.+?$/ then
		location = status.text.gsub("@waku_P\supdate_location\s","")
		next if location.length > 30
		next if ng_word?(location)
		@client.update_profile(:location => location)
		option = {"in_reply_to_status_id" => status.id.to_s}
		tweet = "私は#{location}にいます(@#{status.user.screen_name}さん情報)"
		@client.update tweet,option
	end
end
