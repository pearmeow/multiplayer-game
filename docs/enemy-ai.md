# 简单敌人 AI

把 par_enemy 或继承它的敌人放进房间即可启用。未更改任何房间布置。

- 复用 DashKitten.yyz 的 obj_hunter：state=0/1/2（待机/追踪/目标不存在时回家）、出生点、220px发现范围、16px回家容差；保留当前项目的一枪击杀接口。
- 不复用 platformer 的跳跃/重力/落地检测、依赖 gameplay_stopped() 和 respawn_player() 的部分。
- 当前目标是 obj_player 实体，不是幽灵。速度120px/s，实际碰撞框接触玩家后停止；本次没有新增接触伤害。
- 默认8px四方向均匀网格，BFS保证此网格上的最短路径，不宣称连续空间任意角度的最短路线。四向连接不切墙角。
- 墙体按 max(hit_radius, 实际碰撞框四侧偏移) + wall_margin 外扩，默认14+4=18px。旋转/缩放/偏心贴图也保守使用最大包围半径。
- 网格禁止与外扩墙体相交的整格，所以会比4px更宽松一些。小于安全宽度的通道不可通行。
- 每0.35秒重建墙体占用并重算路线，支持墙体增加、删除、移动。每次位移最多1px，再用完整安全碰撞框检测，阻挡时停下并重算，不贴墙滑动、不瞬移。
- 目标堵塞/不可达时走到最近可达格；出生点本来就在墙或安全边距内则不强行挤出，nav_status=blocked_spawn，应修正布置。
- 每个敌人保有独立网格，Cleanup销毁；小规模原型使用。大批量敌人可再改为按尺寸共享导航网格。

## 入口
objects/par_enemy/Create_0.gml：可调参数、ai_update；Step_0.gml调用更新；CleanUp_0.gml释放网格。
scripts/enemy_navigation/enemy_navigation.gml：安全范围、BFS、路径跟随。
子对象覆写Create/Step/Cleanup时应调用event_inherited()。

发现玩家后不再因距离增大放弃追踪。接触实际碰撞框后停止，玩家脱离碰撞后立即重新寻路继续追踪；没有伤害或血量逻辑。
