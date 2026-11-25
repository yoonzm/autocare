-- 待收银不再提供退回修改，移除旧客户端可调用的数据库操作。
drop function if exists public.staff_order_return(uuid, uuid, text);
