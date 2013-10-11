require 'data_mapper'
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/lws')

class Subscription 
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :email,      String    # A varchar type string, for short strings
  property :created_at, DateTime  # A DateTime, for any date you might like.

  validates_format_of :email, :as => :email_address
end

DataMapper.finalize
