# SUBMIT 动态 ALV

通过 `zcl_my_tools=>submit_alv` 或系统中的等价帮助类执行报表并接收动态 ALV 时：

- 参数表使用 `TABLE OF rsparams`，追加前先清空。
- 选择条件使用 `kind = 'S' sign = 'I' option = 'EQ'`；PARAMETERS 使用 `kind = 'P'`。
- 返回值使用 `REF TO data`，先判断 `IS BOUND`，再动态分配并检查 `sy-subrc`。
- 结果映射优先使用 `CORRESPONDING #( )`，保留目标内表已有内容时使用 `VALUE #( BASE ... )`。
- 以 MCP 或实际方法签名确认帮助类参数，不擅自替换为 `SUBMIT ... AND RETURN`。

```abap
TYPES: BEGIN OF ty_tab,
         raw_line TYPE string,
       END OF ty_tab.

DATA gt_parameters TYPE TABLE OF rsparams.
DATA lr_data TYPE REF TO data.
DATA lt_submit_alv TYPE STANDARD TABLE OF ty_tab WITH EMPTY KEY.
FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

CLEAR gt_parameters.
APPEND VALUE #( selname = 'S_BUKRS' kind = 'S' sign = 'I' option = 'EQ' low = '1234' ) TO gt_parameters.
lr_data = zcl_my_tools=>submit_alv( iv_program = 'ZMM038' it_parameters = gt_parameters ).

IF lr_data IS BOUND.
  ASSIGN lr_data->* TO <lt_data>.
  IF sy-subrc = 0.
    LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data>).
      lt_submit_alv = VALUE #( BASE lt_submit_alv ( CORRESPONDING #( <ls_data> ) ) ).
    ENDLOOP.
  ENDIF.
ENDIF.
```

PARAMETERS 示例：

```abap
APPEND VALUE #( selname = 'P_XD' kind = 'P' low = 'X' ) TO gt_parameters.
```
