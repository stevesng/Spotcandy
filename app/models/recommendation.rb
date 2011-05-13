class Recommendation < ActiveRecord::Base
  belongs_to :candy
  belongs_to :user
end
