# 01 元数据层 Metadata

位置：每个技能目录的 `SKILL.md` 顶部 YAML frontmatter。

```yaml
---
name: abap-coding
description: 编写或修改 ABAP 程序时使用。
---
```

作用：让 VS Code/Copilot 发现技能，并根据 `description` 判断何时加载。
