class Analytics::MonthlyReportsController < Analytics::AnalyticsController
  
  def index
    @affiliate = params[:id].blank? ? nil : Affiliate.find_by_id(params[:id])
    @today = Date.today
    @report_date = params[:date].blank? ? @today : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month)
  end
end