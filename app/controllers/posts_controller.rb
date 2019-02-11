class PostsController < ApplicationController
  def new
    @h = params[:h]
  end

  def search
    contents = { content: render_to_string(partial: 'posts/items.html.erb', locals: {books: search_by_amazon(params[:keyword]), index_number: params[:index]}) }
    render json: contents
  end

  def make
    generate(to_uploaded(params[:imgData]), params[:hash])
    data = [Rails.env]
    render :json => data
  end

  private

  def search_by_amazon(keyword)
    # デバッグ出力用/trueで出力
    Amazon::Ecs.debug = true

    # AmazonAPIで検索
    results = Amazon::Ecs.item_search(
      keyword,
      search_index:  'Books',
      dataType: 'script',
      response_group: 'ItemAttributes, Images',
      country:  'jp',
    )

    # 検索結果から本のタイトル,画像URL, 詳細ページURLの取得
    books = []
    results.items.each do |item|
      book = {
        title: item.get('ItemAttributes/Title'),
        image: item.get('LargeImage/URL'),
        url: item.get('DetailPageURL'),
      }
      books << book
    end
    books
  end

  def to_uploaded(base64_param)
    content_type, string_data = base64_param.match(/data:(.*?);(?:.*?),(.*)$/).captures
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile << Base64.decode64(string_data)
    file_param = { type: content_type, tempfile: tempfile }
    ActionDispatch::Http::UploadedFile.new(file_param)
  end

  # S3 Bucket 内に画像を作成
  def generate(image_uri, hash)
    bucket.files.create(key: png_path_generate(hash), public: true, body: image_uri)
  end

  # pngイメージのPATHを作成する
  def png_path_generate(hash)
    "images/#{hash}.png"
  end

  # bucket名を取得する
  def bucket
    # production / development / test
    environment = Rails.env
    storage.directories.get("webookshelf-tutorial-#{environment}")
  end

  # storageを生成する
  def storage
    Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID_S3'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY_S3'],
      region: 'ap-northeast-1'
    )
  end
end
