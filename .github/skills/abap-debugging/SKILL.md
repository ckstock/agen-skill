---
name: abap-debugging
description: 排查 ABAP Dump、语法错误、选择屏幕异常、ALV、RFC、数据库读写或结果不一致时使用。
---

# ABAP Debugging

1. 获取完整错误：事务、程序/类、Include、行号、消息、调用栈和输入条件。
2. 判断是语法、运行时、数据、权限、锁、RFC 配置还是传输版本问题。
3. 对比期望值、实际值和权威来源；不要只根据前端提示或截图猜测。
4. 先做最小复现，记录成功和失败输入。
5. 修复后复跑原失败路径，并验证一条正常路径和一条空/错误路径。
6. 若无法连接 SAP 系统，明确标记为静态分析，不能声称业务已验证。

错误证据和排查约定见 [../abap-workflow/references/abap-conventions.md](../abap-workflow/references/abap-conventions.md)。
