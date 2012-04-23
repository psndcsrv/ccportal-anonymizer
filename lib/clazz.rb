class Clazz
  include DataMapper::Resource

  storage_names[:default] = 'portal_classes'

  property :class_id, Serial

  has n, :clazz_students, 'ClazzStudent', :child_key => [:class_id]
  has n, :students, 'Member', :through => :clazz_students, :via => :student
end
