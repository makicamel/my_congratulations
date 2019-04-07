class HomeController < ApplicationController

  def index
    # TODO 複数候補の対応
    engine = Rails.application.credentials.search_engine
    from, transfer, to = home_params[:from], home_params[:transfer], home_params[:to]
    agent = Mechanize.new
    page = agent.get("#{engine[:url]}?#{engine[:from]}=#{from}&#{engine[:transfer]}=#{transfer}&#{engine[:to]}=#{to}&#{engine[:search]}=検索")
    @blocks = {}
    ids = page.search('#results').css('.bk_result')
    @blocks = ids.map do |id|
      {
        time: id.search('.data_tm').inner_text,
        departure_station: id.search('.eki_s .nm').inner_text,
        transfer_station: id.search('.eki .nm')[1].inner_text,
        arrive_station: id.search('.eki_e .nm').inner_text,
        first_route: id.search('.rosen .tm')[0].inner_text,
        second_route: id.search('.rosen .tm')[1]&.inner_text,
      }
    end
  end

  private
  def home_params
    params.permit(:from, :transfer, :to)
  end
end
