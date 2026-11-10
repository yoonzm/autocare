// 小程序配置。公开密钥（publishable key）本来就会随客户端发布，与商户端 App 使用同一个；
// 真正的权限由云函数用会员会话令牌校验，不依赖这个密钥。
// 微信 AppID 在 project.config.json；AppSecret 只放服务器环境变量，绝不能写进小程序。
module.exports = {
  apiBase: 'https://autocare.mymember.ltd/functions/v1/merchant-v1',
  publishableKey: 'sb_publishable_mzNkMTh1lVnIXThevC--Zj_5bG1XkCJ',
  timeout: 15000,
};
