extends ColorRect

var pos = Vector2.ZERO
var t := 0.0
var stop_flag := false

@onready var canvas_region = %CanvasRegion


func check_pointer_in_canvas():
    pos = get_viewport().get_mouse_position() - global_position
    if pos.x < 0 or pos.y < 0 or pos.x > get_rect().size[0] or pos.y > get_rect().size[1]:
        return false
    return true


func set_textures():
    var ichannels = canvas_region.get_textures()
    material.set_shader_parameter("iChannel0", ichannels[0])
    material.set_shader_parameter("iChannel1", ichannels[1])
    material.set_shader_parameter("iChannel2", ichannels[2])
    material.set_shader_parameter("iChannel3", ichannels[3])


func _process(delta):
    if not visible:
        return
        
    if not stop_flag:
        t += delta
        
    material.set_shader_parameter("iResolution", get_rect().size)
    material.set_shader_parameter("iTime", t)
    
    
    if not check_pointer_in_canvas():
        return

    pos = pos.clamp(Vector2.ZERO, get_rect().size) / get_rect().size
    material.set_shader_parameter("iMouse", pos)
