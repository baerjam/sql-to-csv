# sql-to-csv

sql-to-csv is a utility script to simulate a MySQL command prompt that supports returning results in CSV format and redirecting results to a file

## What is it?

Always bothered by the fact that you couldn't return the results of a query from the MySQL command line client in CSV format and/or redirect to a file. 
sql-to-csv is a small utility Ruby script that does both of these things. Making it easy to compy and paste into an email or spreadsheet.

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

Start the prompt:
    
    $ ruby sql-to-cvs.rb
    [sql_to_csv]>

Run a query and print results to screen:
```
[sql_to_csv]> select a.company, count(*) as count from users u, accounts a where u.account_id=a.id group by a.company order by count desc;
  Company,Count
  Sprockets Inc,10
  Dunder Mifflen,4
  A-Tech LLC,3
  TestCo,3
```

To redirect results to a file. Append > /path/to/file.csv after semi-colon in query
```
[sql_to_csv]> select a.company, count(*) as count from users u, accounts a where u.account_id=a.id group by a.company order by count desc; > /tmp/results.csv
```

