class DiyMember
  include DataMapper::Resource

  storage_names[:diy] = 'users'

  property :id, Serial
  property :first_name, String
  property :last_name, String
  property :sds_sail_user_id, Integer

  def name
    "#{first_name} #{last_name}"
  end
end

