import { admin, authOnly, resolveSession, fail, json, uuid, url } from './shared.ts';
import { screenshot } from './support_rules.ts';
import { publicStorageUrl } from './storage_url.ts';
import type { Input } from './types.ts';

export async function handleMedia(input: Input, request: Request): Promise<Response> {
 const auth = await authOnly(request);
 if ('response' in auth) return auth.response;
 const session = await resolveSession(auth.user.id,auth.token,true);
 if (session instanceof Response) return session;
 if (request.headers.get('x-store-id') && request.headers.get('x-store-id') !== session.store) return fail('当前门店已变化，请重新打开',409);
 const store = String(input.action).startsWith('store_media_');
 const action = String(input.action).replace(store ? 'store_media_' : 'staff_task_photo_','');
 if (!['list','upload','remove'].includes(action)) return fail('不支持的图片操作');
 if (store ? session.role !== 'owner' : !session.staffId) return fail('暂无权限',403);
 const target = store ? session.store : input.target_id;
 if (!uuid(target)) return fail('图片所属记录无效');
 const args = {p_store:session.store,p_user:auth.user.id,p_staff:session.staffId ?? null,p_kind:store?'store':'task',p_target:target};
 const call = async (extra: Record<string,unknown>) => {
  const result = await admin.rpc('merchant_media_mutate',{...args,...extra});
  if (result.error) throw result.error;
  return result.data;
 };
 const bucket = admin.storage.from('merchant-media');
 const visible = async (r: {id:string;path:string}) => {
  const signed = await bucket.createSignedUrl(r.path,300);
  if (signed.error || !signed.data) throw new Error('media_sign_failed');
  return {id:r.id,url:publicStorageUrl(signed.data.signedUrl,url,Deno.env.get('SUPABASE_PUBLIC_URL')||url)};
 };
 try {
  if (action==='list') {
   const data = await call({p_action:'list'});
   return json({items:await Promise.all(data.items.map(visible))});
  }
  const id = action==='upload' ? request.headers.get('x-request-id') : input.id;
  if (!uuid(id)) return fail('图片请求标识无效');
  if (action==='remove') {
   const row = await call({p_action:'remove',p_id:id});
   if (!row) return json({ok:true});
   const removed = await bucket.remove([row.path]);
   if (removed.error) return fail('图片已隐藏，存储清理失败，请重试',503);
   return json({ok:true});
  }
  const file = screenshot(input.data);
  if (!file) return fail('请选择5MB以内的JPEG或PNG图片');
  const hash = await crypto.subtle.digest('SHA-256',file.bytes as BufferSource);
  const digest = Array.from(new Uint8Array(hash),v=>v.toString(16).padStart(2,'0')).join('');
  const row = await call({p_action:'begin',p_id:id,p_digest:digest,p_extension:file.extension});
  if (row.state!=='ready') {
   const uploaded = await bucket.upload(row.path,file.bytes,{contentType:file.mime,upsert:false});
   // 同一ID的内容摘要已经由事务校验，重复上传只接受存储的409冲突。
   if (uploaded.error && String(uploaded.error.statusCode)!=='409') return fail('图片上传失败，请重试',503);
   await call({p_action:'finish',p_id:id});
  }
  return json({item:await visible(row)});
 } catch(error) {
  const message = String((error as {message?:string}).message ?? error);
  if (message.includes('media_forbidden')) return fail('图片不存在或无权操作',403);
  if (message.includes('media_limit')) return fail(store?'最多上传9张门店照片':'最多上传6张施工照片');
  if (message.includes('media_request_reused')) return fail('图片请求已失效，请移除后重新选择',409);
  if (message.includes('media_missing')) return fail('图片已被移除，请刷新',409);
  return fail('图片操作失败，请重试',503);
 }
}
