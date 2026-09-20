# ABAP 资产索引

| 需求 | 参考规范 | 可复用资产 | 系统组件候选 |
|---|---|---|---|
| 选择屏幕文本 | `references/selection-screen.md` | `components/selection-screen-text.abap` | 选择屏幕事件 |
| 经典 ALV | `references/alv/classic-alv.md` | `components/classic-alv.abap` | `scripts/generate-classic-alv.ps1` |
| Excel 报表模板 | `references/report-template-compiler.md` | `tools/report-template.spec.example.json` | `scripts/compile-report-template.py` |
| SUBMIT 动态 ALV | `references/alv/submit-alv.md` | `components/submit-alv.abap` | `zcl_my_tools=>submit_alv` |
| HTTP/JSON | `references/integration/http-json.md` | `components/http-json.abap` | `zcl_https` |
| 邮件附件 | `references/integration/mail-attachment.md` | `components/send-mail-attachment.abap` | `zcl_api=>send_mail_attachment` |
| ABAP 运维 | `references/operations/` | `operations/` | 以目标系统工具为准 |

## 复用规则

1. 先读取匹配的参考规范和资产代码。
2. 核对目标 SAP 系统中的真实类、方法签名、字段和异常。
3. 组件不存在或签名不匹配时，才设计新实现。
4. `z*` 名称、程序名和示例参数都是系统候选或示例，不可跨系统盲目复制。

## 经典 ALV 生成器

需要快速生成 ALV 骨架时，使用 `scripts/generate-classic-alv.ps1`，输入 JSON 规格文件。规格文件中的 `controls` 决定哪些 layout 控制字段被写入输出行结构；脚本会同步生成对应 layout 引用，避免字段只在 layout 中出现。

示例规格：`assets/tools/classic-alv.spec.example.json`。
