#!/usr/bin/env ruby
#
# sql-to-csv
# MySQL results to CSV
# Author: James Baer 

require 'mysql2'
require 'readline'
require 'choice'
require 'yaml'

PROMPT = '[sql_to_csv]> '.freeze
DEFAULT_DB_CONFIG = 'database.yml'.freeze
VERSION = '1.0.0'

Choice.options do
  header ''
  header 'options:'

  option :config do
    short '-c'
    long '--config=PATH'
    desc 'Path to cluster.yml'
    cast String
  end

  option :database do
    short '-d'
    long '--database=NAME'
    desc 'Name of database connection settings to use from config file'
    cast String
    default 'db_prod_one'
  end

  option :version do
    short '-v'
    long '--version'
    desc 'Show version'
    action do
      puts "sql-to-csv v#{VERSION}"
      exit
    end
  end
end

CHOICES = Choice.choices

if CHOICES[:config]
  CONFIG = YAML.load(IO.read(CHOICES[:config]))
elsif File.exist?(DEFAULT_DB_CONFIG)
  CONFIG = YAML.load(IO.read(DEFAULT_DB_CONFIG))
else
  puts "Usage: #{File.basename(__FILE__)} { -c config_file } [-v]"
  exit
end

# :nodoc
class SqlToCsv
  OUTPUT_REGEX = /;(?:\s)?+\>(?:\s)?(?<filename>.+)$/

  def initialize
    @redirect_to_file = false
    @quote_fields = true

    connect
    start_prompt
  end

  def connect
    connection_params = CONFIG[CHOICES[:database]]
    @client = Mysql2::Client.new(host: connection_params['host'],
                                  username: connection_params['username'],
                                  password: connection_params['password'],
                                  database: connection_params['database'])
  end

  def new_output_file
    @new_output_file ||= File.new(@output_file, 'wb')
  end

  def redirecting_to_file?(line)
    if match = line.match(OUTPUT_REGEX)
      @redirect_to_file = true
      @output_file = match[:filename]
    end
  end

  def empty_line?(line)
    if /^\s*$/ =~ line
      Readline::HISTORY.pop
    end
  end

  def check_for_repeated_line(line)
    if Readline::HISTORY.length > 1 && Readline::HISTORY[Readline::HISTORY.length - 2] == line
      Readline::HISTORY.pop
    end
  rescue IndexError
  end

  def print_line(line)
    puts line
    new_output_file.puts line if @redirect_to_file
  end

  def cleanup
    new_output_file.close if @redirect_to_file
    @new_output_file = nil
  end

  def start_prompt
    while line = Readline.readline(PROMPT, true)
      exit if line =~ /(?:ex|qu)it/i

      next if empty_line?(line)

      check_for_repeated_line(line)

      line.gsub!(OUTPUT_REGEX, '') if redirecting_to_file?(line)

      # Execute Query and return new prompt if sytax error
      begin
        results = @client.query(line)
      rescue Mysql2::Error => e
        puts "Mysql Error: #{e}"
        next
      end

      headers = results.fields
      header_line = headers.map(&:capitalize).join(',')
      print_line(header_line)

      results.each(cache_rows: false) do |row|
        result_line = []
        headers.each do |header|
          result_line << row[header]
        end
        print_line(result_line.join(','))
      end
      cleanup
    end
  end
end

SqlToCsv.new
