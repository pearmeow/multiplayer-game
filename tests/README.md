# Runtime checks

coop_runtime_checks.gml 为运行时断言样例，不注册进正式游戏。
在项目副本中，将其放进测试对象 Alarm 0；rm_01 中的 obj_player 完成 Create 后再触发。
失败会 show_error，成功会输出 COOP TESTS PASSED。
测试会创建/销毁临时敌人、墙体和交互物，不能直接放入正式关卡。
