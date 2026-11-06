import {admin,fail,json,sessionId,userFor} from './shared.ts';
import type {Input} from './types.ts';
export async function handleSupport(input:Input,request:Request):Promise<Response>{
  const auth=await userFor(request);
  if('response' in auth)return auth.response;
  const values={...input};delete values.action;
  const {data,error}=await admin.rpc('merchant_support',{
    p_actor:auth.user.id,p_session:sessionId(auth.token),p_action:input.action,
    p_input:values,p_request:request.headers.get('x-request-id'),
  });
  return error?fail(error.code==='P0002'?'工单不存在':error.code==='P0001'?error.message:'工单操作失败',error.code==='P0002'?404:400):json(data);
}
