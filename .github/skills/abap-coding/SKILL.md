---
name: abap-coding
description: 编写或修改 ABAP 程序、类、函数模块、报表、选择屏幕和数据库逻辑时使用。
---

# ABAP Coding Rules

## [元数据层 Metadata]

顶部 frontmatter 的 `name` 和 `description` 定义本技能的名称和触发场景。

## [指令层 Instruction]

- 先阅读目标对象及其调用方，再决定修改位置。
- 声明放在项目约定的位置，避免在过程逻辑中散落重复声明。
- 选择屏幕字段描述必须使用明确的形式：`%_p_m8_%_app_%-TEXT = 'XXX'.`、`%_p_kurst_%_app_%-TEXT = 'XXX'.`；不得用不兼容的替代写法。
- 检查 SELECT 条件、内表类型、键定义、空结果和重复结果。
- 数据库写入必须说明事务边界、锁、COMMIT/ROLLBACK 和失败恢复。
- 消息使用项目统一消息类和可定位文本；不要遗留临时调试输出。
- RFC、BAPI、ALV 和外部接口要校验返回码、消息表和异常。
- 对用户可见字段、接口字段和 DDIC 对象保持名称与文档一致。

## [资源层 Resource]

详细约定见 [../abap-workflow/references/abap-conventions.md](../abap-workflow/references/abap-conventions.md)。
