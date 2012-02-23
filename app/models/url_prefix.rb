class UrlPrefix < ActiveRecord::Base
  belongs_to :document_collection
  validates_presence_of :prefix
  validates_uniqueness_of :prefix, :scope => :document_collection_id
  validates_format_of :prefix, :with => /^http:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?\/$/ix
  validate :prefix_is_parseable_url
  validates_length_of :prefix, :maximum => 100
  before_validation :ensure_protocol_and_trailing_slash_on_prefix

  def label
    prefix
  end

  private
  def prefix_is_parseable_url
    URI.parse(self.prefix) rescue errors.add(:base, "URL prefix format is not recognized")
  end

  def ensure_protocol_and_trailing_slash_on_prefix
    unless self.prefix.blank?
      self.prefix.strip!
      self.prefix = "http://#{self.prefix}" unless self.prefix =~ %r{^https?://}i
      self.prefix = "#{self.prefix}/" unless self.prefix.ends_with?("/")
    end
  end
end