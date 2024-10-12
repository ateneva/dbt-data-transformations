
# Testing

## Testing source freshnes

```bash
dbt source freshness
```

```plain
16:47:10  Found 1 test, 7 sources, 875 macros
16:47:10
16:47:11  Concurrency: 1 threads (target='dev')
16:47:11
16:47:11  1 of 1 START freshness of thelook_ecommerce.orders ............................. [RUN]
16:47:11  1 of 1 PASS freshness of thelook_ecommerce.orders .............................. [PASS in 0.38s]
16:47:11
16:47:11  Finished running 1 source in 0 hours 0 minutes and 1.51 seconds (1.51s).
16:47:12  Done.
```

## Running tests on sources

```bash
# run test on ALL sources
dbt test --select "source:*"

# run the tests on a specific source
dbt test --select "source:thelook_ecommerce"
```

## Checking source freshness

```bash
dbt source freshness
```

```plain
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations % dbt source freshness
15:11:51  Running with dbt=1.8.2
15:11:53  Registered adapter: bigquery=1.8.1
15:11:54  [WARNING]: Configuration paths exist in your dbt_project.yml file which do not apply to any resources.
There are 2 unused configuration paths:
- models.dbt-data-transformations.the_look.transformations
- models.dbt-data-transformations.the_look
15:11:54  Found 1 model, 1 test, 8 sources, 875 macros
15:11:54
15:11:56  Concurrency: 1 threads (target='dev')
15:11:56
15:11:56  1 of 1 START freshness of thelook_ecommerce.orders ............................. [RUN]
15:11:58  1 of 1 PASS freshness of thelook_ecommerce.orders .............................. [PASS in 1.62s]
15:11:58
15:11:58  Finished running 1 source in 0 hours 0 minutes and 3.99 seconds (3.99s).
15:11:58  Done.
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations %
```
