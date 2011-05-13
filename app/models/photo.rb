class Photo < ActiveRecord::Base

  belongs_to :candy
  
  require 'open-uri'
  has_attached_file :photo, :styles => { :thumb => "110x110#" },
  :storage => :s3,
  :s3_credentials => "#{::Rails.root.to_s}/config/s3.yml",
  :path => "/:id/:style/:filename"
#  :path => ":rails_root/public/images/candies/:id/:style/:basename.:extension",
#  :url => "/images/candies/:id/:style/:basename.:extension"
  
  
  before_validation :download_remote_photo
  
  private

  def download_remote_photo
    self.photo = do_download_remote_photo
  end

  def do_download_remote_photo
    io = open(URI.parse(photo_remote_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
end
