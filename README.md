# Agen Skill

面向 ABAP 开发与运维的 Agent Skill，兼容 VS Code + GitHub Copilot Agent。

## 最终架构

```text
.github/skills/abap/
├─ SKILL.md                         # 元数据层 + 指令层
├─ references/                      # 资源层：规范与任务资料
├─ assets/                          # 资源层：索引、可复用代码和模板
└─ scripts/                         # 资源层：校验脚本
```

`SKILL.md` 是唯一技能入口。它根据任务把请求路由到编码、调试、测试、审查或 ABAP 运维资源，然后由 `assets/INDEX.md` 指向可复用组件。

## 使用方式

在 VS Code 的 Copilot Chat 中描述 ABAP 任务，Agent 会读取 `.github/skills/abap/SKILL.md`。生成代码前先查找 `assets/INDEX.md` 和私有工具集索引，优先复用已有系统封装。

## 边界

Skill 只提供决策规则、参考资料和代码资产；ABAP 语法、ATC、传输检查和真实 SAP 验证仍需在目标开发系统执行。
