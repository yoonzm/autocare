create extension if not exists pg_cron with schema pg_catalog;
-- UTC 16:05 = Shanghai 00:05. Materialization is also run on reads/writes so a
-- delayed scheduler cannot omit due records. Unique keys make both paths safe.
select cron.schedule('autocare-expense-due','5 16 * * *',
  $$select public.expense_materialize(id) from public.stores$$);
