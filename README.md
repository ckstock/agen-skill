# Agen Skill

面向 ABAP 开发的 Agent Skills 框架，兼容 VS Code + GitHub Copilot Agent，并可迁移到其他支持 Agent Skills 标准的工具。

## 目录

- `.github/skills/abap-workflow/`：总入口，负责任务分流和完成前验收
- `.github/skills/abap-coding/`：ABAP 命名、声明位置、选择屏幕和消息规范
- `.github/skills/abap-debugging/`：Dump、RFC、ALV 和运行时问题排查
- `.github/skills/abap-testing/`：语法、ATC、单元测试和真实业务验证
- `.github/skills/abap-review/`：提交前的影响范围、安全和传输对象检查

在 VS Code 中打开 Copilot Chat，输入 `/skills` 可以查看技能；也可以直接描述 ABAP 任务，让 Agent 按 `description` 自动选择技能。

## 设计来源

- [Agent Skills specification](https://agentskills.io/specification)：`SKILL.md`、渐进加载和相对路径资源
- [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)：项目级 `.github/skills/`
- [obra/superpowers](https://github.com/obra/superpowers)：需求澄清、计划、测试、审查和完成前验证
- [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)：面向具体技术栈拆分技能

## 使用边界

Skill 用于指导 Agent；ABAP 语法、ATC、传输检查和真实 SAP 系统验证仍应在你的开发系统中执行。
