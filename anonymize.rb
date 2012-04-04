#!/usr/bin/env ruby

require 'data_mapper'
require File.join(File.dirname(__FILE__), 'lib', 'name_generator.rb')

DataMapper::Logger.new($stdout, :warn)
DataMapper.setup(:default, 'mysql://root@localhost/ccportal2')
DataMapper.setup(:diy, 'mysql://root@localhost/diy')

class DiyMember
  include DataMapper::Resource

  storage_names[:diy] = 'users'

  property :id, Serial
  property :first_name, String
  property :last_name, String

  def name
    "#{first_name} #{last_name}"
  end
end

class ClazzStudent
  include DataMapper::Resource

  storage_names[:default] = 'portal_class_students'

  property :class_student_id, Serial
  property :creation_date,    DateTime
  property :last_update,      DateTime

  belongs_to :clazz, 'Clazz', :parent_key => [:class_id], :child_key => [:class_id]
  belongs_to :student, 'Member', :parent_key => [:member_id], :child_key => [:member_id]
end

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
      user = DiyMember.get(self.diy_member_id)
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

class Clazz
  include DataMapper::Resource

  storage_names[:default] = 'portal_classes'

  property :class_id, Serial

  has n, :clazz_students, 'ClazzStudent', :child_key => [:class_id]
  has n, :students, 'Member', :through => :clazz_students, :via => :student
end

DataMapper.finalize

@seen = []
@seen_names = []
def ensure_unseen(name)
  if @seen_names.include?(name)
    %w{ o a i u e b c d f g h j }.each do |suffix|
      next if @seen_names.include?("#{name[0]}#{suffix} #{name[1]}")
      puts "Duplicate found (#{name.join(" ")}). Adding suffix #{suffix}"
      name[0] += suffix
      break
    end
  end
  @seen_names << name
  return name
end

def anonymize(member, in_progress = [])
  return member if @seen.include?(member)

  others = member.associated_members
  if others.size > 0
    firsts = []
    lasts = []
    others.each do |other|
      if in_progress.include?(other)
        puts "Circular associated_members reference! #{member.member_id} refers to #{other.member_id} which eventually refers back to #{member.member_id}"
        other_first, other_last = ensure_unseen(NameGenerator.get_name(other.member_id))
      else
        other = anonymize(other, in_progress + [member])
        other_first = other.member_first_name
        other_last = other.member_last_name
      end
      firsts << other_first
      lasts << other_last
    end
    member.member_first_name = firsts.join("-")
    member.member_last_name = lasts.join("-")
  else
    member.member_first_name, member.member_last_name = ensure_unseen(NameGenerator.get_name(member.member_id))
  end
  member.save!
  member.update_diy_username

  @seen << member
  return member
end

# First, anonymize all names
Member.all.each do |mem|
  orig_name = mem.name
  anon = anonymize(mem)
  puts "#{orig_name}: #{anon.name} == [#{anon.associated_members.map{|m| m.name}.join(',')}]"
end

# Now ensure that within the class, they are all unique
Clazz.all.each do |cl|
  @seen_names = []
  cl.students.each do |s|
    name = [s.member_first_name, s.member_last_name]
    s.member_first_name, s.member_last_name = ensure_unseen(name)
    s.update_diy_username
    s.save!
  end
end

puts "Done anonymizing user names."
