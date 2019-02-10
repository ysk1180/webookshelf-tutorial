module ApplicationHelper
  def get_twitter_card_info(h)
    twitter_card = {}
    twitter_card[:url] = "https://webookshelf-tutorial.herokuapp.com/?h=#{h}"
    twitter_card[:image] = "https://s3-ap-northeast-1.amazonaws.com/webookshelf-tutorial-production/images/#{h}.png"
    twitter_card[:title] = 'Web本棚'
    twitter_card[:card] = 'summary_large_image'
    twitter_card[:description] = '自分のお気に入りの本をシェアできます'
    twitter_card
  end
end
