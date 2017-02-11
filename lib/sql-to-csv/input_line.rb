module SqlToCsv
  class InputLine
    attr_reader :output_file

    def initialize(line)
      @line = line
      @redirect_to_file = false
      @output_file = nil

      redirect_to_file?
    end

    def user_quit?
      @line =~ /(?:ex|qu)it/i
    end

    def empty?
      @line =~ /^\s*$/
    end

    # removes file redirection portion of line, if supplied
    def to_sql
      @line.gsub(OUTPUT_REGEX, '')
    end

    def redirect_to_file?
      if match = @line.match(OUTPUT_REGEX)
        @redirect_to_file = true
        @output_file = match[:filename]
      end
    end
  end
end
