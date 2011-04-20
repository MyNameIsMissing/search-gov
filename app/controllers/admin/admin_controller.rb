class Admin::AdminController < SslController
  layout "admin"
  before_filter :require_affiliate_admin

  ActiveScaffold.set_defaults do |config|
    config.list.per_page = 100
  end

  private

  def require_affiliate_admin
    return false if require_user == false
    unless current_user.is_affiliate_admin?
      redirect_to home_page_url
      return false
    end
  end

  def default_url_options(options={})
    {}
  end
end