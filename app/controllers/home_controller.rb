class HomeController < ApplicationController

  def index
    # TODO 複数候補の対応
    engine = Rails.application.credentials.search_engine
    from, transfer, to = home_params[:from], home_params[:transfer], home_params[:to]
    agent = Mechanize.new
    page = agent.get("#{engine[:url]}?#{engine[:from]}=#{from}&#{engine[:transfer]}=#{transfer}&#{engine[:to]}=#{to}&#{engine[:search]}=検索")
    @elements = {}
    @elements[:departure_time] = page.search('.data_tm b:nth-child(2)')
    @elements[:arrival_time] = page.search('.data_tm b:nth-child(5)')
  end

  private
  def home_params
    params.permit(:from, :transfer, :to)
  end
end
