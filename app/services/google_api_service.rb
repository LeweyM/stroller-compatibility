class GoogleApiService
  def initialize
    @google_url = "https://www.googleapis.com/customsearch/v1?"
    @cx = ENV['GOOGLE_CLIENT_CX']
    @key = ENV['GOOGLE_CLIENT_API_KEY']
  end

  def image_search(product)
    params = {
      cx: @cx,
      key: @key,
      searchType: "image",
      q: "site:#{product.brand.website} #{product.name}"
    }
    request(@google_url, params)
  end

  def url_search(product)
    params = {
      cx: @cx,
      key: @key,
      q: "site:#{product.brand.website} #{product.name}"
    }
    request(@google_url, params)
  end

  private

  def request(url, params)
    response = HTTParty.get(url, query: params)
    parsed_response = JSON.parse(response.body)
    if parsed_response["searchInformation"]["totalResults"] == 0 or parsed_response["items"].nil?
      raise "No response found for #{@product.name}."
    end
    parsed_response["items"]
  end
end