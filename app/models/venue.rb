class Venue < ActiveRecord::Base
  has_many :candies
  has_many :favorites
  has_many :users, :through => :favorites
  
  serialize :location
  
  @@auth = Authentication.get_keys
  
  def after_initialize
    if self[:location]
      self[:state] = self[:location]['state'] || 'Unknown'
    end
  end
  
  def self.init_venue_history(current_user, refresh = false)
    
    my_foursquare = current_user.authentications.first
    
    #current_user.favorites.where("venuetype = ? ", 1).delete_all
    
    if (my_foursquare && current_user.favorites.where("venuetype = ? ", 1).empty?) || refresh
      #UsersVenue.delete_all(:user_id => current_user.id, :venuetype => 1)
      
      venue_history = JSON.parse(Authentication.req('foursquare').request(
        :get, "https://api.foursquare.com/v2/users/self/venuehistory",
        :client_id => @@auth[:key],
        :client_secret => @@auth[:secret],
        :oauth_token => my_foursquare.access_token))
        
      @my_venues = venue_history['response']['venues']['items']
      
      @my_venues.each do |v|
        item = v['venue']
        
        # Only save popular venues
        if(item['stats']['checkinsCount'] >= 5000)
        
          venue = Venue.find_or_initialize_by_foursquare_id(item['id'])
          
          #venue = current_user.venues.find_or_initialize_by_foursquare_id(item['id'])
          
          attr = {
          :foursquare_id => item['id'], 
          :location => item['location'],
          :name => item['name'],
          :people_count => item['stats']['checkinsCount'],
          :created_at => Time.at(v['lastHereAt'])}

          if venue.update_attributes(attr)
            #user_venue = UsersVenue.find_by_venue_id(venue.id)
            user_venue = current_user.favorites.where("venue_id = ? AND venuetype = ?", venue.id, 1)
            #user_venue.delete if user_venue
            
            if user_venue.empty?
            current_user.favorites.create({:venue_id => venue.id, 
            :venuetype => 1,
            :created_at => Time.at(v['lastHereAt'])})
            end
          end
        
        end
      
      end
    end
  end
  
end
