class SdsSailUser
  include DataMapper::Resource

  storage_names[:sds] = 'sail_users'

  property :id, Serial
  property :first_name, String
  property :last_name, String

  def name
    "#{first_name} #{last_name}"
  end
end

