class Candy < ActiveRecord::Base
  belongs_to :venue
  #has_and_belongs_to_many :users
  has_many :recommendations
  has_many :users, :through => :recommendations
  has_many :photos
  serialize :data
  accepts_nested_attributes_for :photos
  
  def after_initialize
    if self[:data]
      #self[:pic] = self[:data]['photo'] ? self[:data]['photo'].gsub('userpix_thumbs', 'userpix') : '#'
      
      #self[:pic] = self.photos.first ? self.photos.first.photo.url(:original) : self[:data]['photo'].gsub('userpix_thumbs', 'userpix')
#      if self[:is_candy]
#        has_photo = self[:default_photo]
#        
#        self[:thumbnail] = has_photo.nil? ? self[:data]['photo'] : self.photos.empty? ? 
#        self[:data]['photo'] : 
#        self.photos.find_by_id(has_photo) ? self.photos.find_by_id(has_photo).photo.url(:thumb) :
#        self.photos.first.photo.url(:thumb)
#        
#        self[:pic] = has_photo.nil? || self.photos.empty? ? self[:data]['photo'].gsub('userpix_thumbs', 'userpix') : 
#        self.photos.find_by_id(has_photo) ? self.photos.find_by_id(has_photo).photo.url(:original) :
#        self.photos.first.photo.url(:original)
#      else
#
#      end
#        self[:thumbnail] = self[:data]['photo']
#        self[:pic] = self[:data]['photo'].gsub('userpix_thumbs', 'userpix')
    end
    
    # Get the scout who discovered this candy
   # candy_scout = CandiesUser.find_by_candy_id(self.id)
#    self[:scout] = User.find_by_id(candy_scout.user_id) if !candy_scout.nil?
    #self[:scout] = self.users.first if !self.recommendations.empty?
    
    candy_keys = Candy.candy_status_list
    
    if self[:is_candy]
      self[:candy_status] = 
      case self[:score]
      when 0 then nil
      when 1..2 then candy_keys[1][:name]
      when 3..4 then candy_keys[2][:name]
      when 5..6 then candy_keys[3][:name]
      when 7..8 then candy_keys[4][:name]
      when 9..10 then candy_keys[5][:name]
      else candy_keys[6][:name]
      end
    else
      self[:candy_status] = self[:rejected] ? "Rejected" : "Pending"
    end
                
  end
  
  def get_pic(type)
    has_photo = self[:default_photo]
    
    if type == 'thumbnail'
      self[:thumbnail] = has_photo.nil? ? self[:data]['photo'] : self.photos.empty? ? 
      self[:data]['photo'] : 
      self.photos.find_by_id(has_photo) ? self.photos.find_by_id(has_photo).photo.url(:thumb) :
      self.photos.first.photo.url(:thumb)
      
      return self[:thumbnail]
    else
      self[:pic] = has_photo.nil? || self.photos.empty? ? self[:data]['photo'].gsub('userpix_thumbs', 'userpix') : 
      self.photos.find_by_id(has_photo) ? self.photos.find_by_id(has_photo).photo.url(:original) :
      self.photos.first.photo.url(:original)
      
      return self [:pic]
    end
    
  end
  
  def get_scout
    return self.users.where("recommended = true").first
  end
  
  def self.candy_status_list
    return [
    {:name=>"Pending",:count=>0},
    {:name=>"Sweetie",:count=>0}, 
    {:name=>"Rising Star",:count=>0}, 
    {:name=>"Starlet",:count=>0},
    {:name=>"Hot Candy",:count=>0},
    {:name=>"Beauty Queen",:count=>0},
    {:name=>"Super Candy Star",:count=>0},
    {:name=>"Rejected",:count=>0}]
  end
  
  def self.update_profile(candy, access_token)
    @@auth = Authentication.get_keys
    
    #access_token = User.find_by_email('wilson@spotcandy.com').authentications.where("provider = ?",'foursquare').first.access_token
    foursquare_candy = JSON.parse(Authentication.req('foursquare').request(
    :get, "https://api.foursquare.com/v2/users/#{candy.pid}",
    :client_id => @@auth[:key],
    :client_secret => @@auth[:secret],
    :oauth_token => access_token
    ))
      
    candy.data['photo'] = foursquare_candy['response']['user']['photo']
    candy.save
    
    refresh_photo = true
    
    # Save photos with paperclip for candy
    candy_photos = candy.photos
    
    if candy.is_candy && !candy_photos.empty?
      candy_current_photo = candy.data['photo'].gsub('userpix_thumbs', 'userpix')
      
      # New Foursquare Photo
      if candy.photos.find_by_photo_remote_url(candy_current_photo).nil?
      attr = {:default_photo => candy.photos.first.id, :photos_attributes => {candy.photos.count => {:photo_remote_url => candy_current_photo}}}
      candy.update_attributes(attr);
      refresh_photo = true
      else
      refresh_photo = false
      end
      
      
    end
    
    if refresh_photo
      pic = candy.data['photo'].gsub('userpix_thumbs', 'userpix')
      thumbnail = candy.data['photo']
    else
      pic = candy.get_pic('original')
      thumbnail = candy.get_pic('thumbnail')
    end
    
    return candy_photo = {:pic => pic, :thumbnail => thumbnail}
  end
  
end
