# 原型对象与手动配置

## 房间

本次功能实现不通过代码新增、移动或删除关卡实例。你手动保存的房间布局会保留，不自动生成示例布局。
所有门、开关、踩踏触发器和陷阱由你拖入房间。没有固定坐标、固定配对编号或空房间自动生成玩家。

## 直接交互门

直接拖入 obj_door 即可。没有当前房间的触发器与它配对时，幽灵靠近并瞄准门，按Enter 直接开／关。
只有实际存在 target_link 与门的非零 link_id 相同的触发器时，门才只接受触发器控制。
只设置门的编号、但没有对应触发器，仍允许直接交互；删除或解除触发器配对后也会恢复直接交互。
交互距离按门的最近表面计算，门自身不会挡住对自己的视线；其他墙仍会阻挡。
蓝色连线和共享能量消耗规则不变。

## 配一扇由触发器控制的门

1. 从 Asset Browser 拖入 `obj_door` 和 `obj_door_trigger`。
2. 在门实例的 Variables 中把 `link_id` 设为你选择的非零编号。
3. 在开关实例的 Variables 中把 `target_link` 设为相同编号。
4. 幽灵瞄准开关，实体靠近至交互距离内，按Enter 开／关门。

默认编号为 0，表示没有配对。不同组用不同编号；相同编号可以同时控制多个目标。
门的大小、位置和缩放都在房间编辑器里设置。
关闭贴图由 obj_door 的 Sprite 栏配置；打开贴图由 `open_sprite` 资源变量配置。
现有默认素材为 `spr_door_closed` 与 `spr_door_open`，来自 0x72 DungeonTileset II，CC0。
素材原图与来源记录在 assets/doors/0x72，不经过改色或生成。

## 两种触发器

- `obj_door_trigger`：幽灵主动交互类型。
- `obj_trap_trigger`：实体玩家踩踏类型，进入时触发一次，离开后可再次触发。
- `obj_trigger`：通用版本，在 Variables 中用 trigger_kind 选择：0 幽灵交互，1 实体踩踏。

## 配一个陷阱

拖入 `obj_trap` 和 `obj_trap_trigger`，手动设置相同的非零 link_id / target_link。
踩踏触发器会让陷阱在 duration 指定的秒数内开启。
目前开启的陷阱会移除碰到的敌人；尚未实现玩家血量或受伤。
踩踏是自动触发，不额外消耗幽灵主动交互能量。

## 连线效果与能量

- 射击为黄色连线；幽灵主动交互为蓝色连线。
- 两者共用 obj_team 的 action_energy_cost，默认 5；能量不足时不执行。
- obj_player 的 shoot_effect_colour / interact_effect_colour 分别控制颜色。
- action_effect_duration 与 action_effect_width 控制相同的持续时间、线宽。
- 交互只调用视觉效果与目标的 interact，不调用 fire_shot，不会把开关当作敌人射击。

调用顺序：
Enter → obj_aim.update_interaction → obj_team.try_spend → 目标.interact → trigger.activate_targets → door.toggle。
随后调用 obj_player.show_action_effect，Draw 事件按选中的颜色绘制连线。
门打开后关闭碰撞，Draw 事件绘制 open_sprite；关闭后恢复原 Sprite 和碰撞。
门洞中有实体或敌人时不会强制关门。

## 视野与指示箭头

世界物体正常绘制，之后由蒙版遮住视锥外和墙后的区域，不再单独隐藏敌人。
蒙版之后重绘自身实体与幽灵，因此自身角色始终可见；HUD 与最近敌人箭头也不被遮盖。
obj_team 的 indicator_radius / indicator_min_size / indicator_max_size / indicator_far_distance 可在面板中调节。
没有敌人时不显示箭头。箭头朝向最近敌人，距离越近越大。
视锥宽度由 obj_aim 的 cone_width 配置，上下键不再改变它。

## 敌人寻路

采用 GameMaker 的 mp_grid_path，四向移动，按敌人尺寸和 wall_margin 扩大墙体。
每隔 nav_repath_interval 重算。接触玩家后停止，玩家离开后继续追踪。
当前是简化的原型实现，不提供复杂不可达点替代或窄通道修正。

## 可调参数

玩家移动速度、射程、交互范围、幽灵视野范围、敌人速度、网格大小和安全边距等均已移入对应对象的 Variables。
不要把测试副本的实例当作你的关卡布局；运行验证只在 work 下的临时项目中进行。
新增资源后请关闭并重新打开工程，以加载对象变量与事件注册。

## 视野显示参数

obj_aim.vision_range 控制最大视距，以对象变量面板设置为准。obj_team.vision_tint_colour / vision_tint_alpha 控制扇区内淡灰提示色，默认灰色、透明度0.06。
vision_wall_reveal 默认8：视线碰到墙后，沿视线最多再显示8像素；到墙体出口即停止。墙体和敌人的命中检测使用碰撞遮罩与 place_meeting。
vision_brightness 默认0.6，控制视野内世界亮度，自身角色、HUD、箭头不受影响。
vision_edge_fade_angle 默认8度，控制视锥两侧渐变；vision_distance_fade 默认64像素，控制最远端渐变。vision_fade_steps 默认8，控制渐变网格分段。
interaction_key 为对象变量，默认 vk_enter；交互使用普通键盘状态的按下边沿，不再直接轮询右Shift，按住不重复触发。
