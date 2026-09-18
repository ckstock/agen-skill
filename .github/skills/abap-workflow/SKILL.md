---
name: abap-workflow
description: ABAP 项目开发总流程。新增功能、修复 bug、重构、报表、接口、选择屏幕、数据库读写或传输前检查时使用。
---

# ABAP Workflow

## [元数据层 Metadata]

本文件顶部 frontmatter 中的 `name` 和 `description` 用于技能发现和触发匹配。

## [指令层 Instruction]

## 开始前

1. 明确业务目标、输入输出、异常路径和验收口径。
2. 查看 Git 状态和现有差异，保留未授权改动。
3. 判断任务类型并读取对应技能：编码、调试、测试或审查。
4. 涉及公共类、函数模块、BAdI、RFC、数据库写入或接口字段时，先列出调用方和影响范围。
5. 需要实现功能时，先读取 `assets/component-index.yaml`；涉及工具或封装类时，再读取 `assets/tools/abap-tools.yaml`。优先复用现成组件，只有不存在或签名不匹配时才新写实现。

## 实施

- 遵循现有包、类、程序和命名约定。
- 选择屏幕字段描述按项目约定使用 `%_p_m8_%_app_%-TEXT = 'XXX'.` 和 `%_p_kurst_%_app_%-TEXT = 'XXX'.` 等明确形式。
- 业务逻辑与 UI、数据库、外部接口职责分离。
- 不凭猜测修改 DDIC、权限、RFC 或传输对象。
- 遵循简明 Clean Code：方法短小、单一职责、命名表达意图、减少嵌套和重复，明确处理异常、空数据和 `sy-subrc`。
- 新增逻辑应有可复查的验证步骤。

## 完成前

1. 运行语法检查、ATC 或项目规定的静态检查。
2. 验证成功、关键切换、空值/错误路径。
3. 检查消息文本、声明位置、选择条件和可传输对象清单。
4. 同步功能说明、运行手册或接口文档。
5. 报告已验证项、未验证项和剩余风险。

## [资源层 Resource]

- 详细规范：[ABAP conventions](./references/abap-conventions.md)
- 组件索引：[component-index.yaml](./assets/component-index.yaml)
- 私有工具集：[abap-tools.yaml](./assets/tools/abap-tools.yaml)
- 自动检查：[validate-skill-structure.ps1](./scripts/validate-skill-structure.ps1)
- 审查模板：[review-template.md](./assets/review-template.md)
