---
name: abap
description: ABAP 领域统一开发入口，覆盖编码、调试、测试、审查、系统运维，以及邮件、ALV、HTTP/JSON 等现成组件复用。
---

# ABAP 技能入口

本文件同时承担元数据层和指令层；详细规范、代码资产和校验脚本属于资源层。

## 任务路由

先判断任务类型，再读取对应资源：

| 任务 | 先读取 | 再查资产 |
|---|---|---|
| 编码、重构、Clean Code | `references/core.md`、`references/naming.md` | `assets/INDEX.md` |
| 选择屏幕 | `references/selection-screen.md` | `assets/components/selection-screen-text.abap` |
| 经典 ALV | `references/alv/classic-alv.md` | `assets/components/` |
| SUBMIT 动态 ALV | `references/alv/submit-alv.md` | `assets/components/submit-alv.abap` |
| HTTP/JSON | `references/integration/http-json.md` | `assets/components/http-json.abap` |
| 邮件附件 | `references/integration/mail-attachment.md` | `assets/components/send-mail-attachment.abap` |
| 调试、测试、代码审查 | `references/core.md` | `assets/review-template.md` |
| ABAP 运维 | `references/operations/` | `assets/operations/` |

## 执行规则

1. 先读取 `assets/INDEX.md`，再决定使用哪个现成组件。
2. 涉及工具或封装类时读取 `assets/tools/abap-tools.md`，优先查询私有 `ckstock/abap-tools`。
3. 优先复用已有系统组件；只有确认不存在或方法签名不匹配时才新写实现。
4. 以当前 SAP 系统源码、方法签名和 DDIC 定义为准，不凭猜测修改对象。
5. 遵循 Clean Code：方法短小、单一职责、命名表达意图、减少嵌套和重复。
6. 明确处理空数据、返回值、`sy-subrc`、异常、前后台差异和敏感信息。

## 完成前

- 运行适用的语法检查、ATC、ABAP Unit 或真实业务回归。
- 检查成功、关键切换、空值/错误路径。
- 报告已验证项、未验证项和剩余风险。

## 资源层

- 核心规范：[`references/core.md`](references/core.md)
- 资产索引：[`assets/INDEX.md`](assets/INDEX.md)
- 私有工具集：[`assets/tools/abap-tools.md`](assets/tools/abap-tools.md)
- 结构校验：[`scripts/validate-skill-structure.ps1`](scripts/validate-skill-structure.ps1)
