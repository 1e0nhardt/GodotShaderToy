class_name CanvasRegion
extends VBoxContainer

@onready var reset_btn = %ResetBtn
@onready var pause_btn = %PauseBtn
@onready var time_label = %TimeLabel
@onready var fps_label = %FpsLabel
@onready var size_label = %SizeLabel
@onready var title_label = %TitleLabel
@onready var texture_channel = %TextureChannel
@onready var texture_channel_2 = %TextureChannel2
@onready var texture_channel_3 = %TextureChannel3
@onready var texture_channel_4 = %TextureChannel4
@onready var screen_shot_btn = $ToolBar/ScreenShotBtn
@onready var record_video_btn = $ToolBar/RecordVideoBtn
@onready var full_screen_btn = $ToolBar/FullScreenBtn
@onready var main_viewport_canvas = %MainViewportCanvas
@onready var main_canvas = %MainCanvas

@onready var bufferA_canvas = %BufferACanvas
@onready var bufferA_viewport = %BufferAViewport
@onready var bufferA_viewport_canvas = %BufferAViewportCanvas

var pos = Vector2.ZERO
var canvas_size: Vector2
var t := 0.0
var stop_flag := false


func _ready():
    main_canvas.resized.connect(on_resized)
    pause_btn.pressed.connect(on_stop_btn_pressed)
    reset_btn.pressed.connect(on_reset_btn_pressed)

    canvas_size = main_canvas.get_rect().size
    bufferA_viewport.set_size(Vector2(1920, 1080))
    bufferA_viewport_canvas.set_size(Vector2(1920, 1080))
    bufferA_viewport_canvas.material = main_viewport_canvas.material


func _process(delta):
    if not visible:
        return
        
    if not stop_flag:
        t += delta
    
    time_label.text = "%.2f" % t
    fps_label.text = "%.2f" % Engine.get_frames_per_second() 
    
    main_viewport_canvas.material.set_shader_parameter("iResolution", canvas_size)
    main_viewport_canvas.material.set_shader_parameter("iTime", t)
    main_viewport_canvas.material.set_shader_parameter("iChannel0", texture_channel.texture)
    main_viewport_canvas.material.set_shader_parameter("iChannel1", texture_channel_2.texture)
    main_viewport_canvas.material.set_shader_parameter("iChannel2", texture_channel_3.texture)
    main_viewport_canvas.material.set_shader_parameter("iChannel3", texture_channel_4.texture)
    
    if not check_pointer_in_canvas():
        return

    pos = pos.clamp(Vector2.ZERO, canvas_size) / canvas_size
    main_viewport_canvas.material.set_shader_parameter("iMouse", pos)


func check_pointer_in_canvas():
    pos = get_global_mouse_position() - global_position
    if pos.x < 0 or pos.y < 0 or pos.x > canvas_size.x or pos.y > canvas_size.y:
        return false
    return true


func update_canvas_shader(text: String):
    main_viewport_canvas.material.shader.code = text
    # 需要手动刷新一下
    main_viewport_canvas.notify_property_list_changed()


func get_current_texture(use_custom_size=false):
    if not use_custom_size:
        return main_canvas.get_texture()
    else:
        return bufferA_canvas.get_texture()


func get_textures() -> Array[Texture2D]:
    return [
        texture_channel.get_real_texture(), 
        texture_channel_2.get_real_texture(), 
        texture_channel_3.get_real_texture(),
        texture_channel_4.get_real_texture()]


func set_textures(project_data: GodotShaderToyProject):
    texture_channel.load_texture(project_data.channel0)
    texture_channel_2.load_texture(project_data.channel1)
    texture_channel_3.load_texture(project_data.channel2)
    texture_channel_4.load_texture(project_data.channel3)
    
    
func on_resized():
    canvas_size = main_canvas.get_rect().size
    main_viewport_canvas.get_viewport().set_size(canvas_size)
    size_label.text = "%sx%s" %[canvas_size.x, canvas_size.y]


func on_stop_btn_pressed():
    stop_flag = !stop_flag


func on_reset_btn_pressed():
    t = 0.0
