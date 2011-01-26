class User < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :contact_name
  validates_presence_of :api_key
  validates_uniqueness_of :api_key
  validate_on_create :valid_government_affiliation?
  attr_protected :is_affiliate, :is_affiliate_admin, :is_analyst
  has_and_belongs_to_many :affiliates
  before_validation :generate_api_key
  after_validation_on_create :set_is_affiliate
  after_create :ping_admin
  after_create :welcome_user
  attr_accessor :government_affiliation

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Emailer.deliver_password_reset_instructions(self)
  end

  def to_label
    contact_name
  end
  
  def is_affiliate_or_higher
    is_affiliate || is_affiliate_admin || is_analyst
  end

  def is_developer?
    !is_affiliate_or_higher
  end

  private
  
  def ping_admin
    Emailer.deliver_new_user_to_admin(self)
  end

  def welcome_user
    Emailer.deliver_welcome_to_new_user(self)
  end
  
  def generate_api_key
    self.api_key = Digest::MD5.hexdigest("#{contact_name}:#{email}:#{Time.now.to_s}") if self.api_key.nil?
  end

  def set_is_affiliate
    unless self.government_affiliation.blank?
      self.is_affiliate = self.government_affiliation == "1" ? 1 : 0
    end
  end

  def valid_government_affiliation?
    if self.government_affiliation.blank?
      errors.add_to_base("An option for government affiliation must be selected")
    end
  end
end
