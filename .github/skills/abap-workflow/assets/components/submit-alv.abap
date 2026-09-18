" Reusable pattern: verify the system helper signature before use.
DATA gt_parameters TYPE TABLE OF rsparams.
DATA lr_data TYPE REF TO data.
FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

CLEAR gt_parameters.
APPEND VALUE #( selname = 'S_BUKRS' kind = 'S' sign = 'I' option = 'EQ' low = '1234' ) TO gt_parameters.
lr_data = zcl_my_tools=>submit_alv(
  iv_program    = 'ZMM038'
  it_parameters = gt_parameters ).

IF lr_data IS BOUND.
  ASSIGN lr_data->* TO <lt_data>.
  IF sy-subrc = 0.
    " Map <lt_data> with CORRESPONDING #( ) after confirming the target type.
  ENDIF.
ENDIF.
