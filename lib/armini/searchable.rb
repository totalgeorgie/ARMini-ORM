require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = []
    param_values = []
    params.each do |attr_name, value|
      where_line << "#{attr_name} = ?"
      param_values << value
    end
    where_line = where_line.join(" AND ")
    self.parse_all(DBConnection.execute(<<-SQL, *param_values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL
    )
  end
end