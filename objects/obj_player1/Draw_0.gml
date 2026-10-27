draw_self()

var cone_start_x = x + line_length * dcos(cone_start_degree)
var cone_start_y = y + line_length * dsin(cone_start_degree)
draw_line(x, y, cone_start_x, cone_start_y)

var cone_end_x = x + line_length * dcos(cone_end_degree)
var cone_end_y = y + line_length * dsin(cone_end_degree)
draw_line(x, y, cone_end_x, cone_end_y)