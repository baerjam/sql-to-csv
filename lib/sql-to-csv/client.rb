module SqlToCsv
  PROMPT = '[sql-to-csv]> '.freeze
  OUTPUT_REGEX = /;(?:\s)?+\>(?:\s)?(?<filename>.+)$/

  class Client
    def initialize(options = {})
      @redirect_to_file = false
      @quote_fields = options[:quote_fields]
      @history = Readline::HISTORY
      @options = options
      @connection = establish_connection
    end

    def self.start(options)
      new(options).prompt
    end

    # Establish connection to database via supplied connection parameters
    #
    # Will automatically prompt user for password
    def establish_connection
      @client = Mysql2::Client.new(
        host: @options[:host],
        username: @options[:user],
        password: password_prompt,
        database: @options[:database],
        reconnect: true
      )
    rescue Mysql2::Error => e
      raise ConnectionError, "Error connecting to database #{e}"
    end

    # create new command line prompt that accepts
    # sql statements and file redirection options
    def prompt
      newline
      while line = Readline.readline(PROMPT, true)
        input_line = SqlToCsv::InputLine.new(line)

        exit if input_line.user_quit?
        next if input_line.empty?

        # remove current statement from Readline::HISTORY
        @history.pop if line_repeated?(line)

        # Execute query and return new results object
        # go to new prompt if syntax error
        begin
          results = SqlToCsv::Results.new(
            @connection.query(input_line.to_sql),
            input_line.output_file,
            @options[:quote_fields]
          )
        rescue Mysql2::Error => e
          puts "Error: #{e}"
          next
        end

        results.print
      end
    end

    private

    def line_repeated?(line)
      @history.length > 1 && @history[@history.length - 2] == line
    end

    def password_prompt
      print 'Password: '
      STDIN.noecho(&:gets).chomp
    end

    def newline
      puts ''
    end
  end
end
