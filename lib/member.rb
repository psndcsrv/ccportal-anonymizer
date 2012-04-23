class Member
  include DataMapper::Resource

  storage_names[:default] = 'portal_members'

  property :member_id,          Serial
  property :member_username,    String
  property :member_first_name,  String
  property :member_last_name,   String
  property :member_email,       String
  property :associated_members, String
  property :diy_member_id,      Integer

  property :last_update,        DateTime
  property :creation_date,      DateTime

  has n, :clazz_students, 'ClazzStudent', :child_key => [:member_id]
  has n, :clazzes, 'Clazz', :through => :clazz_students, :via => :clazz

  def update_diy_username
    DataMapper.repository(:diy) {
      user = ::DiyMember.get(self.diy_member_id)
      if user
        # puts "Updating diy member: #{user.name} => #{name}"
        user.first_name = member_first_name
        user.last_name = member_last_name
        user.save!
      else
        puts "No diy user for: #{name}"
      end
    }
  end

  def update_sds_username
    DataMapper.repository(:sds) {
      sail_user = ::SdsSailUser.get(self.sds_member_id)
      if sail_user
        sail_user.first_name = member_first_name
        sail_user.last_name = member_last_name
        sail_user.save!
      else
        puts "No sail user for: #{name}"
      end
    }
  end

  def associated_members
    mems = attribute_get(:associated_members).split(',').uniq
    mems.delete(0)
    mems.delete('0')
    mems.map do |m_id|
      Member.get(m_id)
    end
  end

  def name
    "#{member_first_name} #{member_last_name}"
  end
end

