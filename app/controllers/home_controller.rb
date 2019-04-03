class HomeController < ApplicationController

  def index
    from, to = home_params[:from], home_params[:to]
    url = ''
    agent = Mechanize.new
    page = agent.get("#{url}?eki1=#{from}&eki2=#{to}&S=検索")
    @elements = page.search('.bk_result')
  end

  private
  def home_params
    params.permit(:from, :to)
  end
end
