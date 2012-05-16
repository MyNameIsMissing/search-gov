class CommonSubstring < ActiveRecord::Base
  belongs_to :indexed_domain
  validates_presence_of :substring, :indexed_domain_id, :saturation
  validates_uniqueness_of :substring, :scope => :indexed_domain_id

  after_create :remove_from_indexed_documents

  private

  def remove_from_indexed_documents
    indexed_domain.indexed_documents.find_each(:conditions => ['body like ?', '%' + substring + '%']) do |idoc|
      idoc.remove_common_substring(substring)
    end
  end
end