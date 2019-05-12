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
# TODO: 経由が徒歩だった時の対応
# TODO: 経由駅が複数候補ある時の対応(山口(山口), 山口(愛知) 新宿, 新宿三丁目 対応)
    structure = File.open("lib/yasuri.yaml"){|f| f.read}
    root = Yasuri.yaml2tree(structure)
    agent = Mechanize.new
    root_page = agent.get(url)
    @routes = root.inject(agent, root_page).map{|hash| hash.deep_transform_keys{|key| key.to_sym}}
    @routes.each do |route|
      arrow = ' → '
      route[:transfers][:station] = route[:transfers][:station].map{|transfer| transfer[:list]}
                                      .unshift(route[:stations][:departure]).push(route[:stations][:arrive])
      route[:overview] = route[:transfers][:station].join(arrow)
      route[:transfers][:time] = route[:transfers][:time].map{|transfer| transfer[:list]}
      route[:transfers][:line] = route[:transfers][:line].map{|transfer| transfer[:list]}
    end
    p @routes
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
