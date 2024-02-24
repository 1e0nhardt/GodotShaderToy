extends PanelContainer

@export var jfa_scene: PackedScene

@onready var raw_image: TextureRect = %Raw
@onready var ret_image: TextureRect = %Result
@onready var open_dialog: FileDialog = %OpenFileDialog
@onready var confirm_button: Button = %ConfirmButton
@onready var save_channel_button = %SaveChannelButton
@onready var save_file_button = %SaveFileButton
@onready var container = $VBoxContainer

var image_path: String
var default_texture = preload("res://icon.svg")


func _ready():
    confirm_button.disabled = true


func hide_save_buttons():
    save_channel_button.hide()
    save_file_button.hide()


func _on_open_button_pressed():
    open_dialog.popup()


func _on_confirm_button_pressed():
    var instance = jfa_scene.instantiate()
    container.add_child(instance)
    var img = await instance.do_jfa(image_path)
    ret_image.texture = ImageTexture.create_from_image(img)
    save_channel_button.show()
    save_file_button.show()
    Logger.debug(image_path)


func _on_cancel_button_pressed():
    get_parent().hide()
    hide_save_buttons()
    raw_image.texture = default_texture
    ret_image.texture = default_texture


func _on_open_file_dialog_file_selected(path:String):
    image_path = path
    confirm_button.disabled = false
    raw_image.texture = Helper.load_external_image(path)


func _on_save_channel_button_pressed():
    EventBus.jfa_to_channel_committed.emit(ret_image.texture)
    _on_cancel_button_pressed()


func _on_save_file_button_pressed():
    Helper.save_png(
        ret_image.texture.get_image(), 
        "user://jfa_results/", 
        image_path.split("/")[-1].insert(0, "jfa_")
    )
    _on_cancel_button_pressed()
