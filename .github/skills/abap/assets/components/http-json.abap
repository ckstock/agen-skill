" Reusable pattern: use the project's existing HTTP wrapper and secure runtime credentials.
DATA(ls_result) = NEW zcl_https( )->get_url(
  iv_type = '9' )->set_json(
  iv_json = lv_json )->set_type(
  iv_type = 'J' )->set_basic_auth(
  iv_username = lv_username
  iv_password = lv_password )->post( ).

IF ls_result-error_text IS NOT INITIAL.
  rtype = 'E'.
  rtmsg = CONV #( ls_result-error_text ).
ELSE.
  rtype = 'S'.
  rtmsg = CONV #( ls_result-json ).
ENDIF.
