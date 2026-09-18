# Agen Skill 三层架构总览

此目录只用于让人一眼看懂架构，不是一个要被 Agent 触发的技能目录。

```text
.github/skills/
├── 00-ARCHITECTURE/       # 架构说明目录（人读）
│   ├── 01-METADATA/       # 元数据层：发现和触发
│   ├── 02-INSTRUCTION/    # 指令层：步骤和验收
│   └── 03-RESOURCE/       # 资源层：资料、脚本、模板
├── abap-workflow/         # 可加载技能：总流程
├── abap-coding/           # 可加载技能：编码
├── abap-debugging/        # 可加载技能：调试
├── abap-testing/          # 可加载技能：测试
└── abap-review/           # 可加载技能：审查
```

三个层级的详细说明见对应文件夹。真正供 VS Code/Copilot 加载的目录必须包含 `SKILL.md`，所以五个 `abap-*` 目录保持在 `.github/skills/` 的第一层。
