require 'readline'
require 'mysql2'
require 'io/console'

module SqlToCsv
  class SqlToCsVError < StandardError
  end

  class ConnectionError < SqlToCsVError
  end

  class QueryError < SqlToCsVError
  end
end

require 'sql-to-csv/client'
require 'sql-to-csv/input_line'
require 'sql-to-csv/results'
require 'sql-to-csv/version'
