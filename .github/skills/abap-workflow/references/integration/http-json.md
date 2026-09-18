# HTTP 与 JSON

- 优先使用系统中实际存在的 HTTP 帮助类和方法签名。
- 区分传输/帮助类错误与业务 JSON 错误。
- 保留用户代码中的 `rtype`、`rtmsg` 返回习惯；有正式响应结构时优先结构化解析 JSON。
- 用户现有接口明确返回文本时，可按已验证格式检查 `"success":false`。
- 用户名、密码、Token 和密钥来自安全配置或运行时变量，不写死在示例中。

```abap
DATA(ls_result) = NEW zcl_https( )->get_url(
  iv_type = '9' )->set_json(
  iv_json = lv_json )->set_type(
  iv_type = 'J' )->set_basic_auth(
  iv_username = lv_username
  iv_password = lv_password )->post( ).

IF ls_result-error_text IS NOT INITIAL.
  rtype = 'E'.
  rtmsg = CONV #( ls_result-error_text ).
ELSEIF ls_result-json CS '"success":false'.
  rtype = 'E'.
  rtmsg = CONV #( ls_result-json ).
ELSE.
  rtype = 'S'.
  rtmsg = CONV #( ls_result-json ).
ENDIF.

IF rtmsg IS INITIAL.
  rtmsg = COND #( WHEN rtype = 'S' THEN 'OA推送成功' ELSE 'OA推送失败，接口未返回信息' ).
ENDIF.
```
