require 'config/environment'

task :modify do
   UsersVenue.all.each do |v| 
   f = Favorite.create({:user_id => v.user_id, :venue_id => v.venue_id, :venuetype => v.venuetype, :created_at => v.created_at})
   puts f
   end
end

task :addgender do
  User.all.each do |u| 
    auth = u.authentications.first; 
    if auth
      u.gender = auth.data['gender']
      u.save
    end
  end
end