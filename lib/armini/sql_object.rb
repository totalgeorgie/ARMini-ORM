require_relative 'db_connection'
require_relative 'relation'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'

class SQLObject < Relation
  extend Associatable
  extend Searchable
  
  def self.columns
    col_names = DBConnection.execute2("SELECT * FROM #{self.table_name}").first.map! do |col| 
      col.to_sym
    end
    
    col_names.each do |col|
      define_method("#{col}") { self.attributes[col] }
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    parse_all(DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      SQL
    )
  end
  
  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
   parse_all(DBConnection.execute(<<-SQL)
     SELECT
       #{self.table_name}.*
     FROM
       #{self.table_name}
     WHERE
       #{self.table_name}.id = #{id.to_s}
     SQL
     ).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = self.class.columns.drop(1)
    question_marks = (["?"] * col_names.length).join(", ")
    col_names = col_names.join(", ")
    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    col_names = self.class.columns
    params.each do |attr_name, value|
      unless col_names.include?(attr_name.to_sym)
        raise Exception.new("unknown attribute '#{attr_name}'")
      end
      self.attributes[attr_name.to_sym] = value
    end
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    col_names = self.class.columns.drop(1)
    col_names = col_names.join(" = ?, ") << " = ?"
    DBConnection.execute(<<-SQL, *self.attribute_values.drop(1), self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = ?
    SQL
  end

  def attribute_values
    attr_values = []
    self.attributes.each_value do |value|
      attr_values << value
    end
    attr_values
  end
end