/// 少于这个时间的请求不显示任何加载指示，避免闪烁。
const kIndicatorDelay = Duration(milliseconds: 300);

/// 加载指示一旦出现，至少停留这么久。
const kIndicatorMinShow = Duration(milliseconds: 500);

/// 普通请求超时；上传、导出用 [kLongTimeout]。
const kRequestTimeout = Duration(seconds: 15);
const kLongTimeout = Duration(seconds: 60);

/// 内容替换骨架的淡入时长。
const kFadeIn = Duration(milliseconds: 150);
