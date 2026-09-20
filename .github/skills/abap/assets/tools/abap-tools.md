# ABAP 工具集资产

`abap-tools.yaml` 指向私有仓库 [ckstock/abap-tools](https://github.com/ckstock/abap-tools)。它是 ABAP 代码生成时的优先复用来源。

在 VS 工作区需要实际读取工具源码时，将该仓库以同级目录检出为 `tools/abap-tools`；该目录已被 `.gitignore` 排除，不会进入 `agent-abap` 提交。若未检出或当前账号无权限，Copilot 只能使用这里的索引和已登记示例，必须明确说明未读取工具源码。

使用顺序：

1. 在工具集仓库中搜索当前能力对应的类、函数、模板或示例。
2. 确认目标 SAP 系统已经安装对象。
3. 读取真实方法签名后再生成调用代码。
4. 工具集不可访问时，明确说明限制，不凭空重写同类实现。

工具集源码不复制进 `agent-abap`，避免私有实现泄露和版本分叉。
