-- Shared system defaults for registration and every subsequent store.
-- Snapshot generated from merchant-v1/defaults.ts by tools/store_starter_snapshot.ts.
create table public.store_starter_templates(version integer primary key,data jsonb not null);
alter table store_starter_templates enable row level security;
revoke all on store_starter_templates from public,anon,authenticated;
grant select on store_starter_templates to service_role;
insert into store_starter_templates values(1,$template${
  "services": [
    {
      "category": "镀晶镀膜",
      "name": "全车镀晶 · 9H 陶瓷",
      "description": "工时 4h · 提成 8%",
      "price": 1580,
      "active": true,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "category": "镀晶镀膜",
      "name": "石墨烯镀膜",
      "description": "工时 6h · 提成 8%",
      "price": 2680,
      "active": true,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "category": "镀晶镀膜",
      "name": "漆面抛光",
      "description": "工时 3h · 提成 ¥60/单",
      "price": 680,
      "active": true,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "category": "镀晶镀膜",
      "name": "镀晶养护",
      "description": "工时 4h",
      "price": 1280,
      "active": true,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "category": "洗车",
      "name": "精致洗车",
      "description": "工时 40min · 提成 ¥8/单",
      "price": 68,
      "active": true,
      "businesses": [
        "洗车美容"
      ]
    },
    {
      "category": "洗车",
      "name": "快速洗车",
      "description": "工时 20min · 提成 ¥4/单",
      "price": 38,
      "active": true,
      "businesses": [
        "洗车美容"
      ]
    },
    {
      "category": "洗车",
      "name": "发动机舱清洗",
      "description": "工时 30min",
      "price": 120,
      "active": false,
      "businesses": [
        "洗车美容"
      ]
    },
    {
      "category": "贴膜",
      "name": "全车隐形车衣",
      "description": "工时 2 天 · 提成 6%",
      "price": 18800,
      "active": true,
      "businesses": [
        "隐形车衣"
      ]
    },
    {
      "category": "内饰",
      "name": "内饰深度清洁",
      "description": "工时 2h · 提成 ¥40/单",
      "price": 380,
      "active": true,
      "businesses": [
        "洗车美容"
      ]
    },
    {
      "category": "内饰",
      "name": "空调杀菌",
      "description": "工时 30min",
      "price": 98,
      "active": true,
      "businesses": [
        "洗车美容"
      ]
    }
  ],
  "products": [
    {
      "name": "中性洗车液 20L",
      "category": "洗护",
      "unit": "桶",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "洗车美容"
      ]
    },
    {
      "name": "超细纤维擦车巾",
      "category": "洗护",
      "unit": "条",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "洗车美容",
        "镀晶镀膜"
      ]
    },
    {
      "name": "9H 陶瓷镀晶液 50ml",
      "category": "镀晶",
      "unit": "瓶",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "name": "玻璃镀膜剂",
      "category": "镀晶",
      "unit": "瓶",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "镀晶镀膜"
      ]
    },
    {
      "name": "TPU 隐形车衣 7.5mil",
      "category": "贴膜",
      "unit": "卷",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "隐形车衣"
      ]
    },
    {
      "name": "改色膜 · 哑光灰",
      "category": "贴膜",
      "unit": "卷",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "改色膜"
      ]
    },
    {
      "name": "机油滤芯",
      "category": "配件",
      "unit": "个",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "保养维修"
      ]
    },
    {
      "name": "空气滤芯",
      "category": "配件",
      "unit": "个",
      "stock": 0,
      "safe": 0,
      "cost": 0,
      "businesses": [
        "保养维修"
      ]
    }
  ],
  "cards": [
    {
      "name": "黑金卡",
      "description": "",
      "discount": 0.9,
      "color": "black",
      "upgrade_recharge": 10000,
      "upgrade_cumulative": 30000,
      "points_multiplier": 2,
      "birthday_gift": "赠精致洗车 2 次",
      "priority_booking": true,
      "validity": "forever"
    },
    {
      "name": "金卡",
      "description": "",
      "discount": 0.95,
      "color": "champagne",
      "upgrade_recharge": 5000,
      "upgrade_cumulative": 10000,
      "points_multiplier": 1.5,
      "birthday_gift": "赠精致洗车 1 次",
      "priority_booking": false,
      "validity": "forever"
    },
    {
      "name": "银卡",
      "description": "",
      "discount": 0.98,
      "color": "silver",
      "upgrade_recharge": 2000,
      "upgrade_cumulative": 3000,
      "points_multiplier": 1,
      "birthday_gift": "",
      "priority_booking": false,
      "validity": "forever"
    },
    {
      "name": "普通会员",
      "description": "扫码免费注册 · 消费累积积分",
      "discount": 1,
      "color": "white",
      "upgrade_recharge": null,
      "upgrade_cumulative": null,
      "points_multiplier": 1,
      "birthday_gift": "",
      "priority_booking": false,
      "validity": "forever"
    }
  ],
  "packages": [
    {
      "name": "精致洗车年卡",
      "price": 1080,
      "validity_months": 12,
      "active": true,
      "items": [
        {
          "service": "精致洗车",
          "count": 20
        }
      ]
    },
    {
      "name": "精致洗车 10 次卡",
      "price": 580,
      "validity_months": 6,
      "active": true,
      "items": [
        {
          "service": "精致洗车",
          "count": 10
        }
      ]
    },
    {
      "name": "内饰深度清洁 6 次卡",
      "price": 1380,
      "validity_months": 12,
      "active": true,
      "items": [
        {
          "service": "内饰深度清洁",
          "count": 6
        }
      ]
    },
    {
      "name": "镀晶养护 3 次卡",
      "price": 2980,
      "validity_months": 12,
      "active": true,
      "items": [
        {
          "service": "镀晶养护",
          "count": 3
        }
      ]
    },
    {
      "name": "空调杀菌 4 次卡",
      "price": 380,
      "validity_months": 6,
      "active": true,
      "items": [
        {
          "service": "空调杀菌",
          "count": 4
        }
      ]
    },
    {
      "name": "新客体验卡",
      "price": 99,
      "validity_months": 3,
      "active": false,
      "items": [
        {
          "service": "精致洗车",
          "count": 3
        }
      ]
    }
  ],
  "bays": {
    "1-3 个": 3,
    "4-6 个": 6,
    "7-10 个": 10,
    "10 个以上": 20
  }
}$template$::jsonb);
create table public.store_catalog_initializations (
 store_id uuid primary key references stores(id) on delete cascade,
 version integer not null, result jsonb not null, initialized_at timestamptz not null default now()
);
alter table store_catalog_initializations enable row level security;
revoke all on store_catalog_initializations from public,anon,authenticated;
grant all on store_catalog_initializations to service_role;
create function public.initialize_store_catalog(p_store uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare shop stores;t jsonb;entry jsonb;items jsonb;service_id uuid;prior jsonb;pkg jsonb;
 sc int:=0;pc int:=0;cc int:=0;kc int:=0;bc int:=0;bay_count int;result jsonb;
begin
 select * into shop from stores where id=p_store for update;
 if not found then raise exception '门店不存在';end if;
 select i.result into prior from store_catalog_initializations i where i.store_id=p_store;
 if found then return prior;end if;
 select data into t from store_starter_templates where version=1;
 if t is null then raise exception '门店初始化模板未发布';end if;
 for entry in select e from jsonb_array_elements(t->'services') e where (e->'businesses') ?| shop.business_types loop
  if not exists(select 1 from service_items where store_id=p_store and name=entry->>'name') then
   insert into service_items(store_id,name,category,description,price,active)
    values(p_store,entry->>'name',entry->>'category',entry->>'description',(entry->>'price')::numeric,(entry->>'active')::boolean);
   sc:=sc+1;
  end if;
 end loop;
 for entry in select e from jsonb_array_elements(t->'products') e where (e->'businesses') ?| shop.business_types loop
  insert into inventory_products(store_id,name,category,unit,stock,safe,cost)
   values(p_store,entry->>'name',entry->>'category',entry->>'unit',0,0,0) on conflict(store_id,name) do nothing;
  if found then pc:=pc+1;end if;
 end loop;
 for entry in select e from jsonb_array_elements(t->'cards') e loop
  -- Include inactive/deleted definitions in the existence check. Never reactivate them.
  if not exists(select 1 from card_types where store_id=p_store and name=entry->>'name') then
   insert into card_types(store_id,name,description,discount,color,upgrade_recharge,upgrade_cumulative,points_multiplier,birthday_gift,priority_booking,validity)
    values(p_store,entry->>'name',entry->>'description',(entry->>'discount')::numeric,entry->>'color',(entry->>'upgrade_recharge')::numeric,(entry->>'upgrade_cumulative')::numeric,(entry->>'points_multiplier')::numeric,entry->>'birthday_gift',(entry->>'priority_booking')::boolean,entry->>'validity');
   cc:=cc+1;
  end if;
 end loop;
 for pkg in select e from jsonb_array_elements(t->'packages') e loop
  if exists(select 1 from card_packages where store_id=p_store and name=pkg->>'name') then continue;end if;
  items:='[]';
  for entry in select e from jsonb_array_elements(pkg->'items') e loop
   select id into service_id from service_items where store_id=p_store and name=entry->>'service' order by created_at,id limit 1;
   if service_id is null then items:='[]';exit;end if;
   items:=items||jsonb_build_array(jsonb_build_object('service_id',service_id,'count',(entry->>'count')::int));
  end loop;
  if jsonb_array_length(items)=0 then continue;end if;
  perform save_card_package(p_store,null,pkg||jsonb_build_object('purchase_limit',null,'vehicle_scope','全部车型','show_in_mini',true,'description',''),items);
  kc:=kc+1;
 end loop;
 -- Existing booked/custom resources keep their IDs and settings. Fresh stores
 -- use the same range and sequential naming as registration.
 insert into appointment_settings(store_id) values(p_store) on conflict do nothing;
 if not exists(select 1 from appointment_resources where store_id=p_store and kind='bay') then
  bay_count:=coalesce((t->'bays'->>shop.bay_range)::int,3);
  insert into appointment_resources(store_id,kind,name,position)
   select p_store,'bay',n||' 号工位',n from generate_series(1,bay_count) n;
  bc:=bay_count;
 end if;
 result:=jsonb_build_object('services',sc,'products',pc,'cards',cc,'packages',kc,'bays',bc);
 insert into store_catalog_initializations(store_id,version,result) values(p_store,1,result);
 return result;
end $$;
revoke all on function initialize_store_catalog(uuid) from public,anon,authenticated;
grant execute on function initialize_store_catalog(uuid) to service_role;
create or replace function public.merchant_store_mutate(p_user uuid,p_session uuid,p_action text,p_input jsonb,p_request text) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;a merchant_accounts;u account_subscriptions;r merchant_store_requests;s stores;target uuid;n int;lim int;v_name text;v_phone text;v_address text;result jsonb;begin
 -- One account lock serializes quota checks, creates, restores and switches.
 select * into a from merchant_accounts where owner_id=p_user for update;
 state:=platform_merchant_session(p_user,p_session,false);if state?'error' then return state;end if;
 if p_request is null or length(p_request)<1 or length(p_request)>128 then raise exception '缺少请求编号';end if;
 select * into r from merchant_store_requests where owner_id=p_user and request_id=p_request;
 if found then if r.action<>p_action or r.input<>p_input then raise exception '请求编号已用于其他操作';end if;return r.result;end if;
 target:=nullif(p_input->>'id','')::uuid;
 if p_action='switch' then
 select * into s from stores where id=target and owner_id=p_user and archived_at is null;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 insert into merchant_store_sessions values(p_session,s.id) on conflict(session_id) do update set store_id=excluded.store_id;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('archive','restore') then
 select * into s from stores where id=target and owner_id=p_user;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 if p_action='archive' then
 if s.id=a.primary_store_id then raise exception '原门店需保留供旧版本访问，暂不能归档';end if;
 if exists(select 1 from merchant_store_sessions where store_id=s.id) then raise exception '请先将使用该门店的设备切换到其他门店';end if;
 update stores set archived_at=now() where id=s.id;
 else
 select * into u from account_subscriptions where owner_id=p_user for update;
 if u.ends_at<=now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 if s.archived_at is not null and (select count(*) from stores where owner_id=p_user and archived_at is null)>=lim then raise exception '已达套餐门店上限';end if;
 if exists(select 1 from stores where owner_id=p_user and archived_at is null and id<>s.id and name=s.name) then raise exception '已有同名门店';end if;
 update stores set archived_at=null where id=s.id;
 end if;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('create','update') then
 if p_action='create' then
 target:=null; -- A supplied ID cannot bypass duplicate-name checks on creation.
 select * into u from account_subscriptions where owner_id=p_user for update;
 if u.ends_at is null or u.ends_at<=now() or u.starts_at>now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 select count(*) into n from stores where owner_id=p_user and archived_at is null;
 if n>=coalesce(lim,1) then raise exception '已达套餐门店上限，请升级套餐';end if;
 else
 target:=(state->>'store_id')::uuid;
 if p_input->>'id' is distinct from target::text then raise exception '当前门店已变化，请重新打开页面' using errcode='40001';end if;
 end if;
 v_name:=trim(coalesce(p_input->>'name',''));v_phone:=trim(coalesce(p_input->>'phone',''));v_address:=trim(coalesce(p_input->>'address',''));
 if length(v_name) not between 1 and 30 then raise exception '门店名称须为 1–30 字';end if;
 if length(v_address) not between 1 and 300 then raise exception '请选择或输入门店地址';end if;
 if v_phone<>'' and v_phone!~'^[0-9+ -]{6,20}$' then raise exception '请输入正确的门店电话';end if;
 if exists(select 1 from stores where owner_id=p_user and archived_at is null and stores.name=v_name and (target is null or id<>target)) then raise exception '已有同名门店';end if;
 if p_action='create' then
 insert into stores(owner_id,name,phone,address,contact_name,contact_role,business_types,bay_range) select p_user,v_name,v_phone,v_address,contact_name,contact_role,business_types,case when bay_range='' then '1-3 个' else bay_range end from stores where id=a.primary_store_id returning * into s;
 perform initialize_store_catalog(s.id);
 else update stores set name=v_name,phone=v_phone,address=v_address where id=target returning * into s;end if;
 result:=jsonb_build_object('id',s.id);
 else raise exception '不支持的操作';end if;
 insert into merchant_store_requests values(p_user,p_request,p_action,p_input,result);return result;
end $$;


-- Repair existing branches once. Match names without modifying existing rows;
-- no member/order/balance/stock data is copied, reset or manufactured.
do $$declare shop record;begin
 for shop in select s.id from stores s join merchant_accounts a on a.owner_id=s.owner_id where s.id<>a.primary_store_id order by s.id loop
  perform initialize_store_catalog(shop.id);
 end loop;
end $$;
