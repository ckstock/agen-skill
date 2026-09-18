# 邮件附件规范

当系统中存在 `zcl_api=>send_mail_attachment` 且用户需要发送单附件邮件时，遵循以下习惯：

- 收件人和抄送地址使用英文分号分隔；发件人留空时交由当前 SAP 用户或帮助类处理。
- 邮件正文使用纯文本，并可追加操作人和执行时间。
- 文本附件以 UTF-8 编码转换成 `xstring`，附件类型使用 `TXT`。
- 本地文件上传仅支持前台 SAP GUI；后台执行时必须明确返回提示，不能继续调用前台上传 API。
- 二进制文件先上传至 `solix_tab`，再通过 `SCMS_BINARY_TO_XSTRING` 转换为 `xstring`。
- 调用后以 `ev_success` 和 `ev_message` 输出结果；实际投递状态提示用户在 `SOST` 查看。
- 所有字段、方法参数和异常类型必须以 MCP 或当前系统实际定义为准。

核心调用示例（参数较多时分行并对齐）：

```abap
zcl_api=>send_mail_attachment(
  EXPORTING
    iv_mail_from       = lv_mail_from
    iv_mail_to         = CONV string( p_to )
    iv_mail_cc         = CONV string( p_cc )
    iv_mail_title      = lv_title
    iv_mail_body       = lv_body
    iv_filename        = mv_attachment_name
    iv_attachment      = mv_attachment
    iv_attachment_type = lv_attachment_type
  IMPORTING
    ev_success         = lv_success
    ev_message         = lv_message ).
```

UTF-8 TXT 附件示例：

```abap
DATA(lv_text) = |测试内容{ cl_abap_char_utilities=>cr_lf }|.
mv_attachment = cl_abap_codepage=>convert_to( source = lv_text codepage = 'UTF-8' ).
lv_attachment_type = 'TXT'.
```

前台文件上传前的防护示例：

```abap
IF sy-batch = abap_true.
  MESSAGE '本地文件上传不支持后台执行' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.
```

不要在示例中保留真实邮箱地址、密码、Token 或业务文件路径。
