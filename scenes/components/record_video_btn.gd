extends TextureButton

var stop_flag := true:
    set(value):
        stop_flag = value
        self_modulate = Color.WHITE if value else Color.RED
        

func _on_pressed():
    stop_flag = !stop_flag