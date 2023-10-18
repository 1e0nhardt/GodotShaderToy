extends Control

@onready var main_canvas = %MainCanvas
@onready var bottom_canvas0 = %BottomCanvas0
@onready var bottom_canvas1 = %BottomCanvas1
@onready var bottom_canvas2 = %BottomCanvas2
@onready var file_popup: MenuButton = %FileMenu
@onready var tab_container = %TabContainer

func _ready():
    file_popup.get_popup().add_item("保存当前", 0, KEY_MASK_CTRL | KEY_S)
    file_popup.get_popup().add_item("保存所有", 1, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
    file_popup.get_popup().id_pressed.connect(on_id_pressed)


func _on_about_button_pressed():
    %AboutPopupPanel.show()


func _on_about_popup_panel_close_requested():
    %AboutPopupPanel.hide()


func _on_about_popup_panel_size_changed():
    notify_property_list_changed()


func on_id_pressed(id: int):
    if id == 0:
        print("保存成功")
        print(tab_container.get_child(tab_container.current_tab).text)
        print(tab_container.get_child(tab_container.current_tab).name)
    elif id == 1:
        print("保存所有成功")