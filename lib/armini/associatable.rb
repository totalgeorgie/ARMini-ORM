require_relative 'searchable'
require 'active_support/inflector'

#factor out the options classes into their own files

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.class_name = options[:class_name]
    self.foreign_key = options[:foreign_key]
    self.primary_key = options[:primary_key]
    
    self.class_name ||= name.to_s.camelcase.singularize
    self.foreign_key ||= "#{name}_id".to_sym
    self.primary_key ||= :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.class_name = options[:class_name]
    self.foreign_key = options[:foreign_key]
    self.primary_key = options[:primary_key]
    
    self.class_name ||= name.to_s.singularize.camelcase
    self.foreign_key ||= "#{self_class_name.downcase}_id".to_sym
    self.primary_key ||= :id
  end
end

module Associatable
  
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    self.assoc_options[name] = options
    define_method(name) do
      primary_key = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
  
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      thru_options = self.class.assoc_options[through_name]
      src_options = thru_options.model_class.assoc_options[source_name]
      
      thru_foreign_key = self.send(thru_options.foreign_key)
      src_foreign_key = thru_options
                          .model_class
                          .new
                          .send(src_options.foreign_key)
                          
      thru_id = thru_options
                  .model_class
                  .where(thru_options.primary_key => thru_foreign_key)
                  .first
                  .send(src_options.foreign_key)
        
      src_options
        .model_class
        .where(src_options.primary_key => thru_id)
        .first
    end
  end
  
  def has_many_through(name, through_name, source_name)
    define_method(name) do
      #TODO
    end
  end
end