extends ColorRect

var pos = Vector2.ZERO


func check_pointer_in_canvas():
    pos = get_viewport().get_mouse_position() - global_position
    if pos.x < 0 or pos.y < 0 or pos.x > get_rect().size[0] or pos.y > get_rect().size[1]:
        return false
    return true


func _process(_delta):
    if not check_pointer_in_canvas():
        return

    pos = pos.clamp(Vector2.ZERO, get_rect().size) / get_rect().size
    material.set_shader_parameter("mouse_pos", pos)

