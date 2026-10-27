draw_self()
draw_line(x, y, clamp(line_length * dcos(cone_start_degree), 0, room_width), clamp(line_length * dsin(cone_start_degree), 0, room_height))
draw_line(x, y, clamp(line_length * dcos(cone_end_degree), 0, room_width), clamp(line_length * dsin(cone_end_degree), 0, room_height))