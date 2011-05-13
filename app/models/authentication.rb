class Authentication < ActiveRecord::Base
  belongs_to :user
  serialize :data
  
#  @@foursquare_key = "SZRXZ35RWDYOUKV4Y3UHZ2KJD5KWNMCSREQRTUCOECGZMJK5"
#  @@foursquare_secret = "QL2ZJYO3UJ2MEP432U3YJUU3ZUI0DHCXIRKQE5QHXY4MI5EE"
  
  # Remote
  FACEBOOK_ID = '200119013355574'
  FACEBOOK_SECRET = '6ba7aaa43cc9f9a85166e2245a2e8d1d'
  
  # Local
#  FACEBOOK_ID = '140593359342516'
#  FACEBOOK_SECRET = '41162a490cc3854a82bb90d2bddd0634'
  
#  Local
  @@foursquare_key = "5EHFSEXJME4NXODMVAOIVWVBDATOORPTO2CUFYHECZNBGJGM"
  @@foursquare_secret = "5DGGVNA14JSCGF0XIYCFTLFM1ASFYDZYAYZCFIKKVIITIIV4"
  
#  def self.authenticate(provider)
#    
#    case provider
#      when 'foursquare'
#        key = @@foursquare_key
#        secret = @@foursquare_secret
#        options =     {
#         :site               => "http://foursquare.com",
#         :scheme             => :header,
#         :http_method        => :post,
#         :request_token_path => "/oauth/request_token",
#         :access_token_path  => "/oauth/access_token",
#         :authorize_path     => "/oauth/authorize"
#        }
#      when 'facebook'
#        key = @@facebook_appid
#        secret = @@facebook_secret
#        options = {
#        :site => 'https://graph.facebook.com',
#        :request_token_path => "/oauth/request_token",
#        :access_token_path  => "/oauth/access_token",
#        :authorize_path => '/oauth/authorize'
#        }
#    end
#    return OAuth::Consumer.new(key,secret, options)
#  end
  
  def self.req(provider=nil)
    if provider == 'foursquare'
      client = OAuth2::Client.new(
      @@foursquare_key, @@foursquare_secret,  
      :site => {
      :url => 'https://foursquare.com/oauth2/authenticate?response_type=code'
      },
      :authorize_url => 'https://foursquare.com/oauth2/authorize',
      :access_token_url => 'https://foursquare.com/oauth2/access_token?grant_type=authorization_code'
      )
    else
      client ||= OAuth2::Client.new(
        FACEBOOK_ID, FACEBOOK_SECRET, :site => {
            :url=>'https://graph.facebook.com'
        }
      )
    end
    
    return client
  end
  
  def self.get_keys(provider='foursquare')
    case provider
      when 'foursquare'
      return {:key => @@foursquare_key, :secret => @@foursquare_secret}
      when 'facebook'
      return {:key => FACEBOOK_ID, :secret => FACEBOOK_SECRET}
    end
  end

end
