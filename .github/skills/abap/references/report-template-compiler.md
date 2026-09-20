# Excel 报表模板编译器

Excel 模板是报表定义输入，不是 ABAP 源码。建议把工作簿视为一个小型 DSL：

| 工作表 | 作用 |
|---|---|
| `选择屏幕` | 屏幕字段、参考表/字段、必填标志、单值/范围、描述、默认值 |
| `取数逻辑` | 取数步骤和业务规则；生成器只生成占位点，核心 SQL 由开发者确认 |
| `按钮设置` | PF-STATUS、功能码和用户命令 |
| `自定义表` | 输出字段和参考 DDIC 字段 |
| `分类信息` | 报表分类、程序元数据或后续路由信息 |

推荐流程：

```text
Excel/JSON -> 规范化中间模型 -> 校验 -> ABAP 模板渲染
```

## 两种模式

### 新建报表

使用 `scripts/compile-report-template.py --mode new-report`。Excel 或 JSON 是事实来源，生成器负责输出：

- `PARAMETERS` / `SELECT-OPTIONS`
- 输出行类型和 ALV 控制字段
- `lvc_s_layo` 布局
- 字段目录
- `REUSE_ALV_GRID_DISPLAY_LVC` 外壳

`取数逻辑` 只生成明确的 TODO 占位点。SQL、JOIN、权限和业务校验仍需按目标系统确认，避免把 Excel 文本误当成可执行 SQL。

### 运维改已有程序

使用 `--mode maintenance`，同时传入 `--source existing.abap`。源程序是事实来源，生成器只输出 `maintenance-plan.json`，列出模板中要求的选择屏幕、字段和按钮变化，不自动重排、覆盖或套用新建报表模板。

这样可以避免旧程序使用 `REUSE_ALV_GRID_DISPLAY`、类 ALV、Include、全局宏或项目自定义封装时被错误改写。

## 字段一致性

新建模式启用 ALV layout 控制字段时，必须在输出行类型中同步声明对应组件。生成前检查：

- `box_fname` 对应 `sel`
- `countfname` 对应 `count`
- `info_fname` 对应 `line_color`
- `ctab_fname` 对应 `cell_color`
- `stylefname` 对应 `cellstyles`

如果模板只提供了选择屏幕字段和报表字段，可以先生成框架；取数逻辑、按钮事件和 DDIC 类型需要后续补充。
