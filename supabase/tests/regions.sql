-- Run after migrations in a disposable database; changes are rolled back.
begin;
do $$
declare payload jsonb; previous_version text;
begin
  payload := public.region_dictionary();
  assert jsonb_array_length(payload->'items') > 3000, 'dictionary truncated';
  assert (select count(*) from public.regions where level = 1) = 34, 'missing province';
  assert not exists (
    select 1 from public.regions child left join public.regions parent on parent.code = child.parent_code
    where child.level > 1 and (parent.code is null or parent.level != child.level - 1)
  ), 'invalid hierarchy';
  assert (select count(*) from public.regions where parent_code = '500100') = 38, 'Chongqing counties missing';
  assert (select level from public.regions where code = '419001') = 2, 'Jiyuan not selectable as city';
  assert not exists(select 1 from public.regions where parent_code = '441900'), 'towns mixed into district tier';
  assert not has_table_privilege('anon', 'public.regions', 'SELECT'), 'anonymous table access';
  assert not has_table_privilege('authenticated', 'public.regions', 'UPDATE'), 'client can mutate dictionary';
  assert not has_function_privilege('anon', 'public.region_dictionary()', 'EXECUTE'), 'anonymous RPC access';
  previous_version := payload->>'version';
  update public.regions set name = name || 'test' where code = '330100';
  assert (public.region_dictionary()->>'version') != previous_version, 'version did not change';
end $$;
rollback;
