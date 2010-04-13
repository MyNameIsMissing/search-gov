class AddAffiliateToDailyQueryStats < ActiveRecord::Migration
  def self.up
    add_column :daily_query_ip_stats, :affiliate, :string, :limit => 32
    add_column :daily_query_stats, :affiliate, :string, :limit => 32
  end

  def self.down
    remove_column :daily_ip_query_stats, :affiliate
    remove_column :daily_query_stats, :affiliate
  end
end
