class Relation
  def criteria
    @criteria ||= {:conditions => {}}
  end
  
  def where(args)
    self.criteria[:conditions].merge!(args)
    self
  end
  
  def limit(limit)
    self.criteria[:limit] = limit
    self
  end
  
  def where_sql_prep
    where_line = []
    @param_values = []
    where_line << "WHERE " unless self.criteria.length == 0
    @criteria.each do |conditions, values|
      values.each do |criteria|
        where_line << "#{criteria[0]} = ?"
        param_values << criteria[1]
      end
    end
    where_line.join(" AND ").gsub!(/^WHERE  AND/, 'WHERE')
  end

  def method_missing(method, *args, &block)
    unless Array.respond_to?(method.to_sym)
      raise "That method really is missing"
    end
    
    where_clause = where_sql_prep

    self.parse_all(DBConnection.execute(<<-SQL, *self.param_values)
    SELECT
      *
    FROM
      *
    #{where_clause}
    SQL
    ).method yield
  end
end