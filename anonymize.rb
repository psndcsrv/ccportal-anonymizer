#!/usr/bin/env ruby

require 'data_mapper'
require File.join(File.dirname(__FILE__), 'lib', 'name_generator.rb')

DataMapper::Logger.new($stdout, :warn)
DataMapper.setup(:default, 'mysql://root@localhost/ccportal2')
DataMapper.setup(:diy, 'mysql://root@localhost/diy')
DataMapper.setup(:sds, 'mysql://root@localhost/sds')

require File.join(File.dirname(__FILE__), 'lib', 'sds_sail_user.rb')
require File.join(File.dirname(__FILE__), 'lib', 'diy_member.rb')
require File.join(File.dirname(__FILE__), 'lib', 'clazz.rb')
require File.join(File.dirname(__FILE__), 'lib', 'member.rb')
require File.join(File.dirname(__FILE__), 'lib', 'clazz_student.rb')

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
  member.update_sds_username

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
