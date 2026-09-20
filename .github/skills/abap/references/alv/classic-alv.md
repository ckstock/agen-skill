# 经典 ALV 规范

当用户要求生成与其经典 ALV 模板相似的程序时，按以下结构组织：

- 使用 Report + `FORM` 的程序组织方式，常见顺序为权限检查、取数、排除按钮、注册事件、字段目录、布局和显示。
- 经典网格优先使用 `REUSE_ALV_GRID_DISPLAY_LVC`，传入 `i_callback_program`、PF-STATUS、用户命令、布局、字段目录、排除功能和事件表。
- 常用全局对象和内表命名：`gt_show`、`gs_show`、`gt_fieldcat`、`gs_fieldcat`、`gs_layout`、`go_alv`、`git_events`、`gt_excluding`。
- 输出结构按需包含 `sel`、`count`、`line_color`、`cell_color`、`cellstyles`、`checkbox` 等 ALV 控制字段，不要无条件全部添加。
- 布局按需设置列宽优化、斑马线、选择模式、框选字段、计数、行颜色、单元格颜色、可编辑样式和合计位置。
- 用 `FORM set_fieldcat USING ...` 填充并追加字段目录，追加后 `CLEAR gs_fieldcat`。
- 事件通过 `slis_t_event` 注册；需要全屏网格对象时使用 `GET_GLOBALS_FROM_SLVC_FULLSCR`。
- 用户命令中先调用 `check_changed_data`，再按 `sy-ucomm` 处理返回、退出、双击和自定义功能码，并按需设置刷新标记。
- 选择屏幕可使用 block、function key 和 `AT SELECTION-SCREEN OUTPUT` / `AT SELECTION-SCREEN`。

关键布局示例：
 DATA: GS_fieldcat     TYPE lvc_s_fcat, 
       Gt_fieldcat     TYPE lvc_t_fcat, 
       GS_layout       TYPE lvc_s_layo. 
       
```abap
CLEAR gs_layout.
gs_layout-cwidth_opt = 'A'.
gs_layout-zebra = 'X'.
gs_layout-sel_mode = 'D'.
gs_layout-box_fname = 'SEL'.
gs_layout-countfname = 'COUNT'.
gs_layout-info_fname = 'LINE_COLOR'.
gs_layout-ctab_fname = 'CELL_COLOR'.
gs_layout-stylefname = 'CELLSTYLES'.
```
使用新式 REUSE_ALV_GRID_DISPLAY_LVC
字段目录示例：

```abap
FORM set_fieldcat USING VALUE(p_ref_table) VALUE(p_ref_field) VALUE(p_fieldname) VALUE(p_text).
  gs_fieldcat-ref_table = p_ref_table.
  gs_fieldcat-ref_field = p_ref_field.
  gs_fieldcat-fieldname = p_fieldname.
  gs_fieldcat-coltext = p_text.
  gs_fieldcat-seltext = p_text.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
ENDFORM.
```

以上是可筛选的规范，不是固定代码清单。表名、字段名、事务码、PF-STATUS、事件处理类和业务逻辑必须以当前需求及 MCP 读取到的系统对象为准。
