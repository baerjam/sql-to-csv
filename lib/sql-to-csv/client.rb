module SqlToCsv
  # Allows you to create a new SqlToCsv prompt
  #
  # To start the client via supplied executable:
  #   $ sql-to-cvs -h localhost -u <username>
  #
  # To start the client directly:
  #   SqlToCsv::Client.start(options)
  #
  # User will automatically be prompted for password
  #
  # Prompt supports:
  #   - File redirection:
  #       [sql-to-csv]> select * from widgets; > /tmp/results.csv
  #   - Query history via up arrow
  class Client
    PROMPT = '[sql-to-csv]> '.freeze

    def initialize(options = {})
      @redirect_to_file = false
      @quote_fields     = options[:quote_fields]
      @history          = Readline::HISTORY
      @options          = options
      @config           = database_config
      @connection       = establish_connection
    end

    def self.start(options)
      new(options).prompt
    end

    # Establish connection to database via supplied connection parameters
    # & automatically prompt user for password
    def establish_connection
      @config[:password] = password_prompt
      @client = Mysql2::Client.new(@config)
    rescue Mysql2::Error => error
      raise ConnectionError, "Error connecting to database #{error}"
    end

    # create new command-line prompt that accepts
    # sql statements and file redirection options
    def prompt
      newline
      while line = Readline.readline(PROMPT, true)
        @current_input_line = SqlToCsv::InputLine.new(line)

        exit if @current_input_line.user_quit?
        next if @current_input_line.empty?

        # remove current statement from Readline::HISTORY
        @history.pop if line_repeated?

        # Execute query and return new results object. new prompt on syntax error
        begin
          results = fetch_results
        rescue Mysql2::Error => error
          puts "Error: #{error}"
          next
        end
        results.print
      end
    end

    private

    def line_repeated?
      @history.length > 1 && @history[@history.length - 2] == @current_input_line.line
    end

    def password_prompt
      print 'Password: '
      STDIN.noecho(&:gets).chomp
    end

    def newline
      puts ''
    end

    def fetch_results
      SqlToCsv::Results.new(
        @connection.query(@current_input_line.to_sql),
        @current_input_line.output_file,
        @options[:quote_fields]
      )
    end

    def database_config
      {
        host: @options[:host],
        username: @options[:user],
        database: @options[:database],
        reconnect: true
      }
    end
  end
end
