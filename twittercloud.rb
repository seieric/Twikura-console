require 'twitter'
require 'uri'
require 'natto'#形態素解析ライブラリmecab用
require 'magic_cloud'#ワードクラウド作成用
require 'date'

#インスタンスの作成
@Twitter = Twitter::REST::Client.new do |c|
  c.consumer_key = "orbM9WzlgGd7DI0Skc1FmQuhq"
  c.consumer_secret = "t4d3Xe1tv9jpVtKOZllCLle5NdJe0pp0FtHONP2B5NkJc1zDRf"
  c.access_token = "1122717622900908032-teXAl1AtaUHm2FEiZKXmkDrUh4RFGI"
  c.access_token_secret = "2ZfqL1qziytyb6HSZUNRhRqOouuVqRetorOQxZYyRZGq4"
end

#ツイートを取得
def getTweets(username, count)
  epoc_count = (count / 200) + 1 #1リクエストで200ツイートがが限界、繰り返し
  tweets = Array[@Twitter.user_timeline(username, {count: 1})][0] #最新の投稿を配列で取得

  epoc_count.times do
    @Twitter.user_timeline(username, {count: 200, max_id: tweets.last.id-1}).each do |t|
      break if tweets.count == count
      tweets << t
    end
  end

  tweets = tweets.map!{|t| t.text} #配列のツイート内容のみ取得
  tweets = tweets.reject!{|t| t.include?("RT")}#RTを削除

  return tweets
end

tweets = getTweets("Suzu_Mg", 100)

#puts tweets #確認用

tweets_non_url = []
tweets.each do |t|
  t = t.gsub("@", "").gsub("#","")#@,#を取り除く
  urls = URI.extract(t) #urlsにURL文字列を格納

  urls.uniq.each do |url|
    t = t.gsub(url, '') #tweets配列の各要素からurlを取り除く
  end

  tweets_non_url << t
end

tweets.clear

nm = Natto::MeCab.new#Mecabを初期化

words = []
tweets_non_url.each do |t|
  wakati = nm.parse(t)
  wakati.force_encoding("UTF-8")#文字コード情報をUTF-8に書き換え
  wakati.delete!("EOS")# 分かち書きの結果に"EOS"が出てくるため除去
  wakati = wakati.split("\n")  # 単語ごとに分割
  wakati.each do |w|
    word = w.split("\t")  # タブ文字前に単語、後に単語の情報があるため分割
    if word[1].include?("形容詞") || word[1].include?("名詞")
      words.push word[0]
    end
  end
end
tweets_non_url.clear

datetime = DateTime.now

#puts words #確認用
font = 'Arial Unicode'
words =  words.group_by(&:itself).map{ |key, value| [key, value.count] }.to_h
cloud = MagicCloud::Cloud.new(words, rotate: :none, scale: :linear, :font_family=>font)
cloud.draw(500, 250).write("#{datetime}.png")
