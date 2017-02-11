## What is it?

sql-to-csv is a small utility gem that allows the results of sql to to be outputted in CSV format or redirected to a file. Making it easy to copy and paste into an email or spreadsheet. It simulates a MySQL command prompt allowing for multiple queries to be run. 

Features:
- Print results as CSV to screen or redirect to file
- Supports up-arrow for query history
- New prompt after each query

No more of this:
```
+----+---------------------------+
| id | name                      |
+----+---------------------------+
|  1 | Blue                      |
|  2 | Orange                    |
|  3 | Red                       |
|  4 | Yellow                    |
|  5 | Black                     |
+----+---------------------------+
```
When you need this:
```
Id,Name
1,Blue
2,Orange
3,Red
4,Yellow
5,Black
```

## Usage

Start the prompt:
    
    $ sql-to-cvs -h localhost -u <username>
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

To redirect results to a file. Append "> /path/to/file.csv" after semi-colon in query
```
[sql_to_csv]> select a.company, count(*) as count from users u, accounts a where u.account_id=a.id group by a.company order by count desc; > /tmp/results.csv
```

