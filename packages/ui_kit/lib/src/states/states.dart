// 空 / 加载 / 错误 / 提示等状态组件已在「前端加载与反馈规范」里定义并由 async_kit 实现，
// 组件库只引用，不重复实现：页面里只允许用这几个组件表达加载、空、错误。
export 'package:autocare_async_kit/async_kit.dart'
    show
        AppError,
        AppErrorType,
        AppSkeleton,
        AppSpinner,
        AppToast,
        EmptyView,
        ErrorView,
        LoadingButton,
        ToastKind;
