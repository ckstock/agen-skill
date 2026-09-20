REPORT z_template_classic_alv.

TYPES:
  BEGIN OF ty_data,
    sel        TYPE char1,
    count      TYPE i,
    dd_handle  TYPE int4,
    line_color TYPE c LENGTH 4,
    cell_color TYPE lvc_t_scol,
    cellstyles TYPE lvc_t_styl,
    checkbox   TYPE char1,
    sep_flag   TYPE char10,
    INCLUDE STRUCTURE mara,
  END OF ty_data.

DATA:
  gt_data     TYPE STANDARD TABLE OF ty_data,
  gs_data     TYPE ty_data,
  gt_fieldcat TYPE lvc_t_fcat,
  gs_fieldcat TYPE lvc_s_fcat,
  gs_layout    TYPE lvc_s_layo,
  go_alv       TYPE REF TO cl_gui_alv_grid.

START-OF-SELECTION.
  SELECT *
    FROM mara
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    UP TO 10 ROWS.

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
    <ls_data>-count = sy-tabix.
  ENDLOOP.

  PERFORM frm_set_layout.
  PERFORM frm_set_fieldcat.
  PERFORM frm_display.

FORM frm_set_layout.
  CLEAR gs_layout.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'D'.
  gs_layout-box_fname  = 'SEL'.
  gs_layout-countfname = 'COUNT'.
  gs_layout-info_fname = 'LINE_COLOR'.
  gs_layout-ctab_fname = 'CELL_COLOR'.
  gs_layout-stylefname = 'CELLSTYLES'.
ENDFORM.

FORM frm_set_fieldcat.
  CLEAR: gt_fieldcat, gs_fieldcat.
  PERFORM set_fieldcat USING 'MARA' 'MATNR' 'MATNR' '物料'.
  PERFORM set_fieldcat USING ' ' ' ' 'COUNT' '条目数'.
  PERFORM set_fieldcat USING ' ' ' ' 'SEP_FLAG' '结果标识'.
ENDFORM.

FORM set_fieldcat USING
  VALUE(p_ref_table)
  VALUE(p_ref_field)
  VALUE(p_fieldname)
  VALUE(p_text).
  CLEAR gs_fieldcat.
  gs_fieldcat-ref_table = p_ref_table.
  gs_fieldcat-ref_field = p_ref_field.
  gs_fieldcat-fieldname = p_fieldname.
  gs_fieldcat-coltext   = p_text.
  gs_fieldcat-seltext   = p_text.
  APPEND gs_fieldcat TO gt_fieldcat.
ENDFORM.

FORM frm_display.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'FRM_SET_PF_STATUS'
      i_callback_user_command  = 'FRM_USER_COMMAND'
      is_layout_lvc            = gs_layout
      it_fieldcat_lvc          = gt_fieldcat
      i_default                = abap_true
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_data
    EXCEPTIONS
      OTHERS                   = 1.
ENDFORM.

FORM frm_set_pf_status USING pt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' OF PROGRAM 'SAPLKKBL' EXCLUDING pt_extab.
ENDFORM.

FORM frm_user_command USING
  p_ucomm    LIKE sy-ucomm
  p_selfield TYPE slis_selfield.
  DATA lo_alv TYPE REF TO cl_gui_alv_grid.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = lo_alv.

  IF lo_alv IS BOUND.
    lo_alv->check_changed_data( ).
  ENDIF.

  CASE p_ucomm.
    WHEN 'BACK' OR '&F03'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR '&F15' OR '&F12'.
      LEAVE PROGRAM.
  ENDCASE.

  p_selfield-refresh = abap_true.
ENDFORM.
