extends Node

@onready var main_canvas = %MainCanvas
@onready var bottom_canvas0 = %BottomCanvas0
@onready var bottom_canvas1 = %BottomCanvas1
@onready var bottom_canvas2 = %BottomCanvas2


func _on_about_button_pressed():
    %AboutPopupPanel.show()


func _on_about_popup_panel_close_requested():
    %AboutPopupPanel.hide()


func _on_about_popup_panel_size_changed():
    notify_property_list_changed()
