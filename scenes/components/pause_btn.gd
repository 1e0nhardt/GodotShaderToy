extends TextureButton

var icon_start = preload("res://assets/icons/icon-start.svg")
var icon_pause = preload("res://assets/icons/icon-pause.svg")

var stop_flag := false:
    set(value):
        stop_flag = value
        texture_normal = icon_start if stop_flag else icon_pause
        

func _on_pressed():
    stop_flag = !stop_flag
