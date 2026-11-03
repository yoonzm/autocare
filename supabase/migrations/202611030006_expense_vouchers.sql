insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('expense-vouchers','expense-vouchers',false,5242880,array['image/jpeg','image/png'])
on conflict(id) do nothing;
-- The bucket intentionally has no browser write policies. Uploads and short-lived
-- signed reads go through merchant-v1, which verifies the owner and store prefix.
