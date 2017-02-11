module SqlToCsv
  class Results
    def initialize(results, file = nil, quote_fields = false)
      @query_results = results
      @file = file
      @quote_fields = quote_fields
    end

    def headers
      @headers ||= @query_results.fields
    end

    def header_line
      headers.map { |f| format_header(f) }.join(',')
    end

    def output_filehandle
      @output_filehandle ||= File.new(@file, 'wb')
    end

    def redirect_to_file?
      !@file.nil?
    end

    def print_line(line)
      puts line
      output_filehandle.puts line if redirect_to_file?
    end

    def format_field(field)
      @quote_fields ? "\"#{field}\"" : field
    end

    def format_header(header)
      format_field(header.capitalize)
    end

    def print
      print_line(header_line)

      @query_results.each(cache_rows: false) do |row|
        result_line = []
        headers.each do |header|
          result_line << format_field(row[header])
        end
        print_line(result_line.join(','))
      end
      cleanup
    end

    private

    def cleanup
      output_filehandle.close if redirect_to_file?
      @output_filehandle = nil
    end
  end
end
