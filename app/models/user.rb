class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable, :recoverable
  devise :trackable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  
  has_many :authentications, :dependent => :destroy
  #has_and_belongs_to_many :candies
  has_many :recommendations
  has_many :candies, :through => :recommendations
  has_many :favorites
  has_many :venues, :through => :favorites
  #has_and_belongs_to_many :venues
  
  before_save :ensure_authentication_token

  def apply_auth(auth)
    self.email = auth[:email] if email.blank?
    authentications.build(:provider => auth[:provider], :uid => auth[:uid],
    :access_token => auth[:access_token],
    :data => auth[:data])
  end
  
  # Update user profile
  def self.update_foursquare_profile(current_user)
    
    my_foursquare = current_user.authentications.where("provider = ?",'foursquare').first
    
    if my_foursquare && my_foursquare.data['gender'] != 'female' 
#      @@auth = Authentication.get_keys
#      
#      json_me = JSON.parse(Authentication.req('foursquare').request(
#        :get, "https://api.foursquare.com/v2/users/self",
#        :client_id => @@auth[:key],
#        :client_secret => @@auth[:secret],
#        :oauth_token => my_foursquare.access_token))
#      
#      me = json_me['response']['user']
#      
#      my_foursquare.data = me
#      my_foursquare.save
    else
      my_foursquare = User.find_by_email('wilson@spotcandy.com').authentications.where("provider = ?",'foursquare').first
    end
    return my_foursquare
  end
  
  def get_score
    scout_score = 0
    self.candies.where("recommended = true").each do |candy|
      #scout_score += candy.score if candy.is_candy
      if candy.recommendations.where("recommended = true").first.user_id == self.id
      scout_score += candy.score if candy.is_candy
      else
      scout_score += 1 if candy.is_candy
      end
    end
#    
    return scout_score
    #return self.candies.count
  end
  
  
end
