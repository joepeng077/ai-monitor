# AI Monitor

AI Monitor 是一个本机优先的 macOS 菜单栏工具和 WidgetKit 小组件集合。

> 状态：公开重写版的基础实现。它可以显示 Mac 系统状态，并提供 Codex、Claude、WorkBuddy 三张默认**不读取账户登录态**的小组件。

## 安全边界

- 不提交、读取或上传 API Key、Cookie、令牌、钥匙串、浏览器资料或其他应用私有文件。
- 不含遥测、分析 SDK 或后台服务。
- Codex、Claude、WorkBuddy 的自动账户刷新尚未开放；它们需要先有公开、允许使用的数据方式与单独的隐私审查。
- 所有图标均使用 macOS 系统符号；本项目与 OpenAI、Anthropic、WorkBuddy 或 CodeBuddy 没有关联或背书关系。

## 本地构建

要求：macOS 14+、Xcode 26+。仓库已包含 Xcode 工程；只有在修改 `project.yml` 后才需要 [XcodeGen](https://github.com/yonaskolb/XcodeGen)。

```sh
xcodebuild -project AIMonitor.xcodeproj -scheme AIMonitor -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

在 Xcode 中选择你的 Development Team 后，即可为自己的 Mac 构建和安装。首次运行后，从系统小组件库添加四张卡片。

## 验证

```sh
swift test
```

更多发布和安全要求见 [docs/SECURITY.md](docs/SECURITY.md)。
