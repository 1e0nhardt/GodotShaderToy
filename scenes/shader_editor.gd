extends Control

const RESET_FILEPATH_LIST = [
    "res://resources/examples/templates/0.text",
    "res://resources/examples/templates/1.text",
    "res://resources/examples/templates/2.text",
    "res://resources/examples/templates/3.text"
]
const TEMP_SHADER_FILEPATH = "res://resources/temp_files/temp.frag"

@onready var canvas_list = [%MainCanvas, %BottomCanvas0, %BottomCanvas1, %BottomCanvas2]
@onready var file_popup: MenuButton = %FileMenu
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var tab_container = %TabContainer
@onready var error_output = %ErrorOutput

var filepath_list = [
    "res://resources/temp_files/0.text",
    "res://resources/temp_files/1.text",
    "res://resources/temp_files/2.text",
    "res://resources/temp_files/3.text"
]
var trigger_file_popup_id = -1
var glsl_error_infomation = []
var glslang_path


func _ready():
    glslang_path = ProjectSettings.globalize_path("res://glslang/bin/glslang.exe")

    # 设置菜单栏
    file_popup.get_popup().add_item("保存当前", 0, KEY_MASK_CTRL | KEY_S)
    file_popup.get_popup().add_item("保存所有", 1, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_S)
    file_popup.get_popup().add_item("另存为", 2, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
    file_popup.get_popup().add_item("重置当前", 3, KEY_MASK_CTRL | KEY_R)
    file_popup.get_popup().add_item("重置所有", 4, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_R)
    file_popup.get_popup().add_item("打开文件", 5, KEY_MASK_CTRL | KEY_O)
    file_popup.get_popup().id_pressed.connect(on_id_pressed)

    # 加载临时shader文件
    for i in canvas_list.size():
        load_tab_text(i)


func sync_text(file_text: String, index: int):
    canvas_list[index].material.shader.code = file_text
    tab_container.get_child(index).text = file_text


func load_tab_text(index: int):
    var file_text = ""
    if FileAccess.file_exists(filepath_list[index]):
        file_text = FileAccess.get_file_as_string(filepath_list[index])
    else:
        file_text = FileAccess.get_file_as_string(RESET_FILEPATH_LIST[index])
        var f = FileAccess.open(filepath_list[index], FileAccess.WRITE)
        f.store_string(file_text)
    # Logger.debug("File: ", file_text)
    sync_text(file_text, index)


func load_file(path: String):
    var file_text = FileAccess.get_file_as_string(path)
    sync_text(file_text, tab_container.current_tab)


func converter(godot_shader_string: String):
    var glsl_shader_string = "#ifdef GL_ES\nprecision mediump float;\n#endif\nuniform float u_time;\n"
    godot_shader_string = godot_shader_string.substr(godot_shader_string.find("//tag") + 5)
    godot_shader_string = godot_shader_string.replace("void fragment()", "void main()")
    godot_shader_string = godot_shader_string.replace("uniform vec2 mouse_pos;", "uniform vec2 u_mouse;")
    godot_shader_string = godot_shader_string.replace("mouse_pose", "u_mouse")
    godot_shader_string = godot_shader_string.replace("TIME", "u_time")
    godot_shader_string = godot_shader_string.replace("UV", "gl_FragCoord.xy")
    godot_shader_string = godot_shader_string.replace("COLOR", "gl_FragColor")
    godot_shader_string = godot_shader_string.replace("FRAGCOORD", "gl_FragCoord")
    godot_shader_string = godot_shader_string.replace("VERTEX", "gl_Position")
    godot_shader_string = godot_shader_string.replace("POINT_SIZE", "gl_PointSize")
    godot_shader_string = godot_shader_string.replace("POINT_COORD", "gl_PointCoord")
    godot_shader_string = godot_shader_string.replace("FRONT_FACING", "gl_FrontFacing")
    return glsl_shader_string + godot_shader_string


func save_tab_text(index: int):
    var current_text = tab_container.get_child(index).text
    canvas_list[index].material.shader.code = current_text
    var f = FileAccess.open(filepath_list[index], FileAccess.WRITE)
    f.store_string(current_text)
    Logger.info("Saving", filepath_list[index])

    var ft = FileAccess.open(TEMP_SHADER_FILEPATH, FileAccess.WRITE)
    ft.store_string(converter(current_text))
    ft.close()

    OS.execute(glslang_path, [ProjectSettings.globalize_path(TEMP_SHADER_FILEPATH)], glsl_error_infomation, true)
    # Logger.debug("Glslang error info", glsl_error_infomation[0])
    if glsl_error_infomation[0] != "":
        error_output.show()
        error_output.text = glsl_error_infomation[0]
    else:
        error_output.hide()
    glsl_error_infomation = []

    if tab_container.get_child(index).name.ends_with("*"):
        tab_container.get_child(index).name = tab_container.get_child(index).name.left(-2)


func save_current_file():
    save_tab_text(tab_container.current_tab)
    Logger.info("保存成功")


func save_all_file():
    for i in canvas_list.size():
        save_tab_text(i)
    Logger.info("保存所有成功")


func reset_tab_text(index: int):
    var file_text = FileAccess.get_file_as_string(RESET_FILEPATH_LIST[index])
    sync_text(file_text, index)


func reset_current_file():
    reset_tab_text(tab_container.current_tab)
    Logger.info("重置成功")


func reset_all_file():
    for i in canvas_list.size():
        reset_tab_text(i)
    Logger.info("重置所有成功")


func change_tab_name(path):
    var tab_name = tab_container.get_child(tab_container.current_tab).name
    if tab_name.ends_with(" *"):
        tab_name = tab_name.left(-1) + path.split("/")[-1].split(".")[0]
    else:
        tab_name = tab_name + " " + path.split("/")[-1].split(".")[0]
    tab_container.get_child(tab_container.current_tab).name = tab_name

    filepath_list[tab_container.current_tab] = path


func on_id_pressed(id: int):
    if id == 0:
        save_current_file()
    elif id == 1:
        save_all_file()
    elif id == 2:
        trigger_file_popup_id = 2
        save_file_dialog.popup()
    elif id == 3:
        reset_current_file()
    elif id == 4:
        reset_all_file()
    elif id == 5:
        trigger_file_popup_id = 5
        open_file_dialog.popup()


func _on_about_button_pressed():
    %AboutPopupPanel.show()


func _on_about_popup_panel_close_requested():
    %AboutPopupPanel.hide()


func _on_about_popup_panel_size_changed():
    notify_property_list_changed()


func _on_file_dialog_file_selected(path):
    if trigger_file_popup_id == -1:
        return

    var current_tab_index = tab_container.current_tab

    # 另存为
    if trigger_file_popup_id == 2:
        var f = FileAccess.open(path, FileAccess.WRITE)
        f.store_string(tab_container.get_child(current_tab_index).text)
        canvas_list[current_tab_index].material.shader.code = tab_container.get_child(current_tab_index).text
        change_tab_name(path)

    # 打开
    elif trigger_file_popup_id == 5:
        Logger.info("Loading: ", path)
        load_file(path)
        change_tab_name(path)


