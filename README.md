# 闲鱼文案悬浮球插件 (dylib)

注入闲鱼 App 后显示可拖动悬浮球，点开设置服务类型/联系方式，AI 一键生成文案并复制。

## 注入方法（企业证书）
1. 解包闲鱼 IPA，把 `libXianyuCopyTweak.dylib` 放进 `Payload/Runner.app/Frameworks/`
2. `install_name_tool` 或直接改 Mach-O 加 `LC_LOAD_DYLIB` 指向 `@executable_path/Frameworks/libXianyuCopyTweak.dylib`
3. 企业证书重签整个 App 后安装
