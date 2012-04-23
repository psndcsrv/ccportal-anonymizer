class ClazzStudent
  include DataMapper::Resource

  storage_names[:default] = 'portal_class_students'

  property :class_student_id, Serial
  property :creation_date,    DateTime
  property :last_update,      DateTime

  belongs_to :clazz, 'Clazz', :parent_key => [:class_id], :child_key => [:class_id]
  belongs_to :student, 'Member', :parent_key => [:member_id], :child_key => [:member_id]
end

