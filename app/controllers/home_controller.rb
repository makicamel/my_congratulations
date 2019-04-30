class HomeController < ApplicationController

  def index
    save_cookie if home_params[:from].present?
    @query = Struct.new(:from, :transfer, :to, :start_time).new(*pick_cookie)

    time_label = [:ym, :dd, :hh, :mn1, :mn2]
    time_value = @query.start_time.split('/').map.with_index{|datetime, index| [time_label[index], datetime] }.to_h
    # TODO 複数候補の対応
    engine = Rails.application.credentials.search_engine
    agent = Mechanize.new
    url = "#{engine[:url]}?#{engine[:from]}=#{@query.from}&#{engine[:transfer]}=#{@query.transfer}&#{engine[:to]}=#{@query.to}&" +
    "Dym=#{time_value[:ym]}&Ddd=#{time_value[:dd]}&Dhh=#{time_value[:hh]}&Dmn1=#{time_value[:mn1]}&Dmn2=#{time_value[:mn2]}&#{engine[:search]}=検索"
    page = agent.get(url)
    p "#{engine[:url]}?#{engine[:from]}=#{@query.from}&#{engine[:transfer]}=#{@query.transfer}&#{engine[:to]}=#{@query.to}&" +
    "Dym=#{time_value[:ym]}&Ddd=#{time_value[:dd]}&Dhh=#{time_value[:hh]}&Dmn1=#{time_value[:mn1]}&Dmn2=#{time_value[:mn2]}&#{engine[:search]}=検索"
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
# TODO: 経由駅が複数になった時の対応、経由が徒歩だった時の対応
# TODO: 経由駅が複数候補ある時の対応
    src = YAML.load_file('lib/yasuri.yaml')
    root = Yasuri.yaml2tree(src)
    agent = Mechanize.new
    root_page = agent.get(url)
    result = root.inject(agent, root_page)
  end

  private
  def pick_cookie
    p cookies[:start_time]
    [cookies[:from], cookies[:transfer], cookies[:to], cookies[:start_time] || Time.now.strftime('%Y%m/%d/%H/%M').insert(-2, '/')]
  end

  def save_cookie
    cookies[:from] = home_params[:from]&.chomp
    cookies[:transfer] = home_params[:transfer]&.chomp
    cookies[:to] = home_params[:to]&.chomp
    cookies[:start_time] = Time.now.strftime('%Y%m/%d/%H/%M').insert(-2, '/')
  end

  def home_params
    params.permit(:from, :transfer, :to)
  end
end
