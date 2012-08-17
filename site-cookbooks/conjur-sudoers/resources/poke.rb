actions :execute

def initialize(*args)
  super
  @action = :execute
end

attribute :name, :kind_of => String, :name_attribute => true
attribute :exclude_groups, :kind_of => Array
attribute :include_groups, :kind_of => Array
attribute :owner, :kind_of => String