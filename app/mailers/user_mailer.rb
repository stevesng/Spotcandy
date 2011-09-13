class UserMailer < ActionMailer::Base
  default :from => "\"Spotcandy\" <noreply@spotcandy.com>"
  
  def welcome_mail(recipient)
    @candies = Candy.where("is_candy = true AND score > 0").limit(6).order("updated_at DESC")
    @candies_1 = @candies.slice(0..2)
    @candies_2 = @candies.slice(3..6)
    
    mail(:to => recipient,
     :subject => "Welcome to Spotcandy") do |format|
     #this is buggy
    #format.html { render 'welcome_mailer' }
    end
  end
  
  # Just spotted checkin in
  def notify_mail(recipient, candy, rand_id, venue)
    @candy = candy
    @venue = venue
    @candies = Candy.where("id >= ? AND is_candy = true AND id != ?", rand_id, @candy.id).limit(3)
    mail(:to => recipient,
     :subject => "Your candy has been spotted!") do |format|
    format.html { render 'notify_mailer' }
    end
  end
  
  # Discovered
  def watch_new_candy_mail(recipient, candy, rand_id)
    @candy = candy
    @candies = Candy.where("id >= ? AND is_candy = true AND id != ?", rand_id, @candy.id).limit(3)
    mail(:to => recipient,
     :subject => "New Candy Notification") do |format|
    format.html { render 'watch_new_candy_mailer' }
    end
  end
  
  def daily_mail(scout,user_candies,candies)
    @candies = candies
    @list = user_candies
      mail(:to => scout.email,
       :subject => "Daily Candy Report") do |format|
      format.html { render 'daily_mailer' }
      end
  end
  
  def join_mail(scout, scout_total)
    @scout = scout
    @scout_total = scout_total
        mail(:to => 'ngerchuyang@gmail.com',
         :subject => "A New Scout has joined Spotcandy") do |format|
      format.text { render 'join_mailer' }
      end
  end
  
  def flag_mail(candy, scout)
    @candy = candy
    @scout = scout
      mail(:to => 'wilson@spotcandy.com',
     :subject => "Spotcandy Flag Notification") do |format|
    format.text { render 'flag_mailer' }
    end
  end
  
  def spot_mail(candy, scout)
    @candy = candy
    @scout = scout
      mail(:to => 'wilson@spotcandy.com',
     :subject => "New Candy Recommendation") do |format|
    format.text { render 'spot_mailer' }
    end
  end
  
  def recommended_mail(candy, recipient, rand_id)
    @candy = candy
    @recommendations = @candy.recommendations.where("recommended = ?", true).count + 1
    
    
    @candies = Candy.where("id >= ? AND is_candy = true AND id != ?", rand_id, @candy.id).limit(3)
#    @candies = Candy.find_by_sql(
#    "SELECT * FROM candies WHERE id >= #{@rand_id} AND is_candy = true AND id != #{@candy.id} LIMIT 3")

    mail(:to => recipient,
     :subject => "Someone has recommended your candy!") do |format|
    format.html { render 'recommended_mailer' }
    end
  end
  
end
