class HomeController < ApplicationController

  def index
    engine = Rails.application.credentials.search_engine
    from, to = home_params[:from], home_params[:to]
    agent = Mechanize.new
    page = agent.get("#{engine[:url]}?#{engine[:from]}=#{from}&#{engine[:to]}=#{to}&#{engine[:search]}=検索")
    @elements = page.search('.bk_result')
  end

  private
  def home_params
    params.permit(:from, :to)
  end
end
