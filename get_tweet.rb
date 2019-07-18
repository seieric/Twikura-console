require 'twitter'
require 'uri'
#require 'natto' #This includes "mecab"
#MECAB_PATH=/usr/lib/x86_64-linux-gnu/libmecab.so.2

#Connection
@Twitter = Twitter::REST::Client.new do |c|
  c.consumer_key = "orbM9WzlgGd7DI0Skc1FmQuhq"
  c.consumer_secret = "t4d3Xe1tv9jpVtKOZllCLle5NdJe0pp0FtHONP2B5NkJc1zDRf"
  c.access_token = "1122717622900908032-teXAl1AtaUHm2FEiZKXmkDrUh4RFGI"
  c.access_token_secret = "2ZfqL1qziytyb6HSZUNRhRqOouuVqRetorOQxZYyRZGq4"
end

#Get Tweets
def getTweets(username, count)
  epoc_count = (count / 200) + 1 #1リクエストで200ツイートがが限界、繰り返し
  tweets = Array[@Twitter.user_timeline(username, {count: 1})][0] #最新の投稿を配列で取得

  epoc_count.times do
    @Twitter.user_timeline(username, {count: 200, max_id: tweets.last.id-1}).each do |t|
      break if tweets.count == count

      tweets << t
    end
  end

  tweet_text = tweets.map!{|t| t.text} #配列のツイート内容のみ取得
  return tweet_text
end

tweets = getTweets("TwitterJP", 100) #tweetsはArray 200Tweets取得

tweets_non_url = Array[]
tweets.each do |t|
  urls = URI.extract(t) #urlsにURL文字列を格納

  urls.uniq.each do |url|
    t.gsub!(url, '') #tweets配列の各要素からurlを取り除く
  end

  tweets_non_url << t
end

tagger = Natto::MeCab.new(output_format_type: :wakati)

wakati_all = Array[]

tweets_without_url.each do |t|
  wakati = tagger.parse(t)
  wakati = wakati.scrub("")
  #wakati.encode("UTF-16", "UTF-8", invalid: :replace, undef: :replace, replace: '').encode("UTF-8" , "UTF-16") #UTF-8と適合しない文字列を置換
  wakati.delete("EOS")
  wakati = wakati.split("\n") #単語ごとに分割し、配列に代入
  wakati_all.push(wakati)
  wakati_all.flatten #wakati_allは全tweetの単語を含む
end

puts wakati_all
words = Array[]

#wakati_all.each do |w|
#  word = w.split("\t")
#  if word[1].include?("形容詞") || word[1].include?("名詞")
#    unless word[0] == "#"
#      words.push word[0]
#    end
#  end
#end
