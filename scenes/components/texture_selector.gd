extends TextureRect

var default_texture = texture

@onready var open_texture_dialog = $OpenTextureDialog

func _ready():
    get_tree().root.files_dropped.connect(on_files_dropped)


func load_texture(t: Texture2D):
    if t:
        texture = t
    else:
        texture = default_texture


func get_real_texture():
    return null if texture == default_texture else texture


func on_files_dropped(paths: Array):
    if not (paths[0].split(".")[-1].to_lower() in ["png", "jpg", "svg", "bmp"] 
        and get_global_rect().has_point(get_global_mouse_position())):
        return
    
    texture = Helper.load_external_image(paths[0])


func _on_gui_input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            open_texture_dialog.popup()
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            texture = default_texture
            EventBus.texture_changed.emit()


func _on_open_texture_dialog_file_selected(path):
    texture = Helper.load_external_image(path)
    EventBus.texture_changed.emit()
