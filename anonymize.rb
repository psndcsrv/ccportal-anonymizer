#!/usr/bin/env ruby

require 'data_mapper'
require File.join(File.dirname(__FILE__), 'lib', 'name_generator.rb')

DataMapper::Logger.new($stdout, :warn)
DataMapper.setup(:default, 'mysql://root@localhost/ccportal2')

class Member
  include DataMapper::Resource

  storage_names[:default] = 'portal_members'

  property :member_id,          Serial
  property :member_username,    String
  property :member_first_name,  String
  property :member_last_name,   String
  property :member_email,       String
  property :associated_members, String

  property :last_update,        DateTime
  property :creation_date,      DateTime

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

DataMapper.finalize

Member.all.each do |mem|
  others = mem.associated_members
  if others.size > 0
    firsts = []
    lasts = []
    others.each do |other|
      other_first, other_last = NameGenerator.get_name(other.member_id)
      firsts << other_first
      lasts << other_last
    end
    mem.member_first_name = firsts.join("-")
    mem.member_last_name = lasts.join("-")
  else
    mem.member_first_name, mem.member_last_name = NameGenerator.get_name(mem.member_id)
  end
  mem.save
end
