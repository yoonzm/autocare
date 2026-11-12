-- 一期限时免费：新注册账号开通完整功能、无到期的内部“限时免费”权益。
-- 沿用试用套餐（kind='trial'）这一内部机制，应用内不再展示任何套餐、订阅或到期信息。

do $$
declare c text;
begin
  for c in select conname from pg_constraint
    where conrelid = 'public.platform_plans'::regclass and contype = 'c'
      and pg_get_constraintdef(oid) like '%trial_days%'
  loop
    execute format('alter table public.platform_plans drop constraint %I', c);
  end loop;
end $$;
alter table public.platform_plans add constraint platform_plans_trial_days_check
  check (trial_days between 14 and 36500);

-- 发布新的试用套餐版本：名称、不限员工数、100 年有效期（等同不过期）。
update public.platform_plans
   set name = '限时免费', trial_days = 36500, staff_limit = null, version = version + 1
 where kind = 'trial';

insert into public.platform_plan_versions (kind, version, snapshot, created_at)
select kind, version, to_jsonb(p), now() from public.platform_plans p where kind = 'trial';

-- 已有试用账号统一转为限时免费；付费 / 模拟订阅账号不变。
-- account_subscription_sync 触发器会同步更新其门店镜像。
update public.account_subscriptions
   set plan_version = (select version from public.platform_plans where kind = 'trial'),
       ends_at = starts_at + interval '36500 days'
 where plan = 'trial' and source = 'trial';
