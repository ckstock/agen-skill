# 经典 ALV 规范

当用户要求生成与个人经典 ALV 模板相似的程序时，按以下结构组织：

- 使用 Report + `FORM` 的程序组织方式，常见顺序为权限检查、取数、排除按钮、注册事件、字段目录、布局和显示。
- 经典网格优先使用 `REUSE_ALV_GRID_DISPLAY_LVC`，传入 `i_callback_program`、PF-STATUS、用户命令、布局、字段目录、排除功能和事件表。
- 常用全局对象和内表命名：`gt_data`、`gs_data`、`gt_fieldcat`、`gs_fieldcat`、`gs_layout`、`go_alv`、`git_events`、`gt_excluding`。
- 输出行结构必须先定义，再由布局引用。`box_fname`、`countfname`、`info_fname`、`ctab_fname`、`stylefname` 引用的每一个字段，都必须是输出内表行类型的真实组件。
- 不要只在 layout 中写控制字段。启用行选择、计数、行颜色、单元格颜色或可编辑样式时，必须同步在输出结构中定义 `sel`、`count`、`line_color`、`cell_color`、`cellstyles` 等字段。
- 只有业务需要时才添加 `checkbox`、`dd_handle`、`sep_flag` 等业务控制字段；字段名、类型和 layout 引用必须保持一致。
- 布局按需设置列宽优化、斑马线、选择模式、框选字段、计数、行颜色、单元格颜色、可编辑样式和合计位置。
- 用 `FORM set_fieldcat USING ...` 填充并追加字段目录，追加后 `CLEAR gs_fieldcat`。
- 事件通过 `slis_t_event` 注册；需要全屏网格对象时使用 `GET_GLOBALS_FROM_SLVC_FULLSCR`。
- 用户命令中先调用 `check_changed_data`，再按 `sy-ucomm` 处理返回、退出、双击和自定义功能码，并按需设置刷新标记。
- 选择屏幕可使用 block、function key 和 `AT SELECTION-SCREEN OUTPUT` / `AT SELECTION-SCREEN`。

## 字段与布局一致性

生成或审查 ALV 时，先检查下面的对应关系：

| Layout 属性 | 必须存在的输出行字段 | 典型类型 |
|---|---|---|
| `box_fname = 'SEL'` | `sel` | `char1` |
| `countfname = 'COUNT'` | `count` | `i` |
| `info_fname = 'LINE_COLOR'` | `line_color` | `c LENGTH 4` |
| `ctab_fname = 'CELL_COLOR'` | `cell_color` | `lvc_t_scol`；若系统模板明确要求，可核对后使用 `slis_t_specialcol_alv` |
| `stylefname = 'CELLSTYLES'` | `cellstyles` | `lvc_t_styl` |

字段名可以使用大写或小写，ABAP 会按不区分大小写处理；但字段必须真实存在，且类型必须与 ALV 控件的接口兼容。`dd_handle`、`checkbox`、`sep_flag` 等字段如果没有被布局、字段目录或业务逻辑使用，不要为了示例完整而强行添加。

推荐的最小模板如下。模板同时定义了 layout 所引用的字段，避免运行时因为组件缺失而 dump：

```abap
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
  gt_data    TYPE STANDARD TABLE OF ty_data,
  gs_data    TYPE ty_data,
  gt_fieldcat TYPE lvc_t_fcat,
  gs_fieldcat TYPE lvc_s_fcat,
  gs_layout   TYPE lvc_s_layo,
  go_alv      TYPE REF TO cl_gui_alv_grid.

gs_layout-cwidth_opt = abap_true.
gs_layout-sel_mode   = 'D'.
gs_layout-box_fname  = 'SEL'.
gs_layout-countfname = 'COUNT'.
gs_layout-info_fname = 'LINE_COLOR'.
gs_layout-ctab_fname = 'CELL_COLOR'.
gs_layout-stylefname = 'CELLSTYLES'.
```

如果项目已有 `cell_color TYPE slis_t_specialcol_alv`，先以目标系统的 `REUSE_ALV_GRID_DISPLAY_LVC` 签名和现有可编译模板为准；不要仅凭字段名替换类型。

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
FORM frm_set_fieldcat .
  CLEAR: gt_fieldcat, gs_fieldcat.
  gs_fieldcat-key = abap_true.
  PERFORM set_fieldcat USING ' ' ' ' 'COUNT' '条目数'.
  gs_fieldcat-icon = abap_true.
  PERFORM set_fieldcat USING ' ' ' ' 'SEP_FLAG' '结果标识'.
  PERFORM set_fieldcat USING 'MARA' 'MATNR' 'MATNR' '物料'.
ENDFORM.

FORM set_fieldcat USING
  VALUE(p_ref_table)
  VALUE(p_ref_field)
  VALUE(p_fieldname)
  VALUE(p_text).
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
