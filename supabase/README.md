# Supabase

开发项目：`autocare-dev`（项目 ID `wghsytekrmpcofpugyua`）。

`migrations/202611010001_merchant_foundation.sql` 已在开发项目 SQL Editor 执行。包含门店、服务项目、会员卡种、会员表，注册时自动创建门店，所有业务表启用 RLS，数据只对门店所有者开放。**不要把 service_role key 或数据库密码放进客户端。**

后续新环境应通过 Supabase CLI 执行迁移；本开发项目此次通过 SQL Editor 手动应用，迁移历史需在首次 CLI 接管时核对/修复，避免重复执行。
