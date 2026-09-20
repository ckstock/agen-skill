" Reusable pattern: verify zcl_api=>send_mail_attachment in the target SAP system first.
发件人用这个 ZCL_API=>MAIL_SENDER
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
