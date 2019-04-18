class HomeController < ApplicationController

  def index
    save_cookie if home_params[:from].present?
    @query = Struct.new(:from, :transfer, :to).new(*pick_cookie)

    # TODO 複数候補の対応
    engine = Rails.application.credentials.search_engine
    agent = Mechanize.new
    page = agent.get("#{engine[:url]}?#{engine[:from]}=#{@query.from}&#{engine[:transfer]}=#{@query.transfer}&#{engine[:to]}=#{@query.to}&#{engine[:search]}=検索")
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
        first_line: id.search('.rosen .rn')[0].inner_text,
        second_line: id.search('.rosen .rn')[1]&.inner_text,
        first_home_begin: id.search('.eki_s .ph').inner_text,
        first_home_end: id.search('.eki .ph div')[1].inner_text,
        second_home_begin: id.search('.eki .ph div')[2]&.inner_text,
        second_home_end: id.search('.eki_e .ph').inner_text,
      }
    end
  end

  private
  def pick_cookie
    [cookies[:from], cookies[:transfer], cookies[:to]]
  end

  def save_cookie
    cookies[:from] = home_params[:from]&.chomp
    cookies[:transfer] = home_params[:transfer]&.chomp
    cookies[:to] = home_params[:to]&.chomp
  end

  def home_params
    params.permit(:from, :transfer, :to)
  end
end
