# 选择屏幕规范

报表选择屏幕需要自定义字段描述时，在 `INITIALIZATION` 中使用 `%_参数名_%_APP_%-TEXT` 赋值，不优先增加冗余的 `SELECTION-SCREEN COMMENT`。

```abap
INITIALIZATION.
  %_P_HOST_%_APP_%-TEXT = 'FTP服务器'.
  %_P_USER_%_APP_%-TEXT = 'FTP账号'.
  %_S_MATNR_%_APP_%-TEXT = '物料号'.
```

- `PARAMETERS` 使用参数名，例如 `%_P_BUKRS_%_APP_%-TEXT`。
- `SELECT-OPTIONS` 使用选择条件名，例如 `%_S_MATNR_%_APP_%-TEXT`。
- 多组条件使用 `SELECTION-SCREEN BEGIN OF BLOCK ... WITH FRAME`，块标题也在初始化时赋值。
- 动态控制输入状态时使用 `AT SELECTION-SCREEN OUTPUT`；输入校验和功能键处理使用 `AT SELECTION-SCREEN`。
