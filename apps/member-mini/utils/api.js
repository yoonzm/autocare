// 调用会员端云函数 member-v1 的 mb_* 接口（与商户端 merchant-v1 分开部署，只共享数据库）。会员身份、门店隔离、价格与规则都在服务端校验，这里只负责传输。
const config = require('../config');
const session = require('./session');

class ApiError extends Error {
  constructor(message, status, type) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    // auth 需要重新登录；network 可重试；notfound 不存在；server 其他
    this.type = type;
  }
}

function typeOf(status) {
  if (status === 401) return 'auth';
  if (status === 0) return 'network';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'notfound';
  if (status >= 500) return 'server';
  return 'client';
}

let onAuthLost = null;
function request(action, data, options) {
  const opts = options || {};
  const current = session.get();
  const header = { 'content-type': 'application/json', apikey: config.publishableKey };
  if (opts.auth !== false && current) header['x-member-token'] = current.token;
  if (opts.requestId) header['x-request-id'] = opts.requestId;
  return new Promise((resolve, reject) => {
    wx.request({
      url: config.apiBase,
      method: 'POST',
      timeout: config.timeout,
      header,
      data: Object.assign({ action }, data || {}),
      success(res) {
        const body = res.data || {};
        if (res.statusCode >= 200 && res.statusCode < 300 && !body.error) return resolve(body);
        const status = res.statusCode || 500;
        const err = new ApiError(body.error || '服务暂时不可用，请稍后重试', status, typeOf(status));
        if (status === 401 && opts.auth !== false && onAuthLost) onAuthLost();
        reject(err);
      },
      fail() {
        reject(new ApiError('网络不可用，请检查网络后重试', 0, 'network'));
      },
    });
  });
}

module.exports = {
  ApiError,
  request,
  /** 登录态失效（令牌过期 / 被撤销）时回调，由 app.js 清理并回到登录页。 */
  setAuthLostHandler(fn) {
    onAuthLost = fn;
  },
  // 业务接口
  login: (loginCode, phoneCode) => request('mb_login', { login_code: loginCode, phone_code: phoneCode }, { auth: false }),
  logout: () => request('mb_logout'),
  stores: () => request('mb_stores'),
  overview: (store) => request('mb_overview', { store_id: store }),
  services: (store) => request('mb_services', { store_id: store }),
  slots: (store, day, serviceIds) => request('mb_slots', { store_id: store, day, service_ids: serviceIds }),
  book: (store, body, requestId) => request('mb_book', Object.assign({ store_id: store }, body), { requestId }),
  appointments: (store, tab) => request('mb_appointments', { store_id: store, tab }),
  appointment: (store, id) => request('mb_appointment', { store_id: store, id }),
  cancel: (store, id, reason) => request('mb_cancel', { store_id: store, id, reason }),
  vehicles: (store) => request('mb_vehicles', { store_id: store }),
  saveVehicle: (store, body) => request('mb_vehicle_save', Object.assign({ store_id: store }, body)),
  card: (store) => request('mb_card', { store_id: store }),
  code: (store) => request('mb_code', { store_id: store }),
  orders: (store, kind, before) => request('mb_orders', { store_id: store, kind, before }),
  order: (store, id) => request('mb_order', { store_id: store, id }),
  rechargeDetail: (store, id) => request('mb_recharge_detail', { store_id: store, id }),
  packages: (store) => request('mb_packages', { store_id: store }),
  rechargeOptions: (store) => request('mb_recharge_options', { store_id: store }),
  recharge: (store, amount) => request('mb_recharge', { store_id: store, amount }),
  buyPackage: (store, id) => request('mb_package_buy', { store_id: store, package_id: id }),
  notices: () => request('mb_notices'),
};
