# Bitemporality

## Testing

1. Create a "bitemporal" database

2. Go to /adapted_scripts

```
cd /adapted_scripts/sql
```

3. execute /sql/\_load_all.sql function:

```
psql -U postgres -p 5452 -h localhost bitemporal < _load_all.sql
```

4. Go to examples/bitemp_tutorial.sql

5. Create bitemporal tables: -- PART 1 - table creation --

6. Create business sequences -- PART 2 - sequences creation --

7. Insert initial data: -- PART 3 - initial insertions --
   7*. -- PART 3* - check initial insertions --

8. Update staff, customer and product -- PART 4 - updates --
   8*. -- PART 4* - check updates --

9. Do corrections -- PART 5 - correction -- Make sure to select the correct asserted time! take it from a previous insertion
   9*. -- PART 5* - check correction --

10. Execute deletion -- PART 6 - delete -- Make sure to select the correct asserted time! take it from a previous insertion

11. Execute deletion -- PART 7 - delete -- Make sure to select the correct asserted time! take it from a previous insertion

## Graphics

1. Go to adapted_scripts/screens
2. open bitemporal.drawio
