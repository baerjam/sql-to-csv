# sql-to-csv

sql-to-csv is a utility script to simulate a MySQL command prompt that supports returning results in CSV format and redirecting results to a file

## What is it?

Always bothered by the fact that you couldn't return the results of a query from the MySQL command line client in CSV format and/or redirect to a file. 
sql-to-csv is a small utility Ruby script that does both of these things.

Features:
- Print results as CSV to screen or redirect to file
- Supports up-arrow for query history
- New prompt after each query

## Usage

You'll need a database.yml file that contains your database connection settings.
Default is ./database.yml but can be changed with the -c /path/to/database.yml option

Here's a sample database.yml:

    production: &production
      adapter: mysql2
      host: 'localhost'
      port: 3306

    app_production:
      <<: *production
      username: '<user>'
      password: '<password>'
      database: '<db_name>'


