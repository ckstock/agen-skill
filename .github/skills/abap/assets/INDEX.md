# ABAP 资产索引

| 需求 | 参考规范 | 可复用资产 | 系统组件候选 |
|---|---|---|---|
| 选择屏幕文本 | `references/selection-screen.md` | `components/selection-screen-text.abap` | 选择屏幕事件 |
| SUBMIT 动态 ALV | `references/alv/submit-alv.md` | `components/submit-alv.abap` | `zcl_my_tools=>submit_alv` |
| HTTP/JSON | `references/integration/http-json.md` | `components/http-json.abap` | `zcl_https` |
| 邮件附件 | `references/integration/mail-attachment.md` | `components/send-mail-attachment.abap` | `zcl_api=>send_mail_attachment` |
| ABAP 运维 | `references/operations/` | `operations/` | 以目标系统工具为准 |

## 复用规则

1. 先读取匹配的参考规范和资产代码。
2. 核对目标 SAP 系统中的真实类、方法签名、字段和异常。
3. 组件不存在或签名不匹配时，才设计新实现。
4. `z*` 名称、程序名和示例参数都是系统候选或示例，不可跨系统盲目复制。
