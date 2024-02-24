extends Control

const SHADER_TEMPLATE_FILEPATH = "res://shaders/template.res"
const TEMP_GDSHADER_FILEPATH = "user://temp.res"

@export var jfa_scene: PackedScene

@onready var file_menu: MenuButton = %FileMenu
@onready var edit_menu: MenuButton = %EditMenu
@onready var help_menu: MenuButton = %HelpMenu
@onready var canvas_region: CanvasRegion = %CanvasRegion
@onready var editor_region = %EditorRegion
@onready var save_file_dialog = %SaveFileDialog
@onready var open_file_dialog = %OpenFileDialog
@onready var full_screen_canvas = $FullScreenCanvas
@onready var app_container = $AppContainer
@onready var popup_layer = $PopupLayer

var canvas_full_screen_flag := false:
    set(value):
        canvas_full_screen_flag = value
        if canvas_full_screen_flag:
            full_screen_canvas.set_textures()
            full_screen_canvas.material.shader.code = editor_region.get_shader_text()
            full_screen_canvas.notify_property_list_changed()
        full_screen_canvas.visible = canvas_full_screen_flag
        app_container.visible = !canvas_full_screen_flag

var drag_offset: Vector2i = Vector2i.ZERO
var dragging := false

var glsl_error_infomation = []
var ffmpeg_path
var settings: Dictionary

var current_filepath = TEMP_GDSHADER_FILEPATH:
    set(value):
        current_filepath = value
        editor_region.update_title(current_title)
var current_title: String:
    get:
        return current_filepath.split("/")[-1].split(".")[0]


var ffmpeg_pid := -5
var ffmpeg_started := false
var video_recording_flag := false:
    set(value):
        video_recording_flag = value
        if not value:
            # 停止录制后，则不再更新导出专用的bufferA_viewport
            canvas_region.bufferA_viewport.set_update_mode(SubViewport.UPDATE_DISABLED) 
            # 将内存中的png buffer导出
            # if len(video_frames) != 0:
            #     var frame_ind = 0
            #     for png_frame in video_frames:
            #         var image = Image.new()
            #         image.load_png_from_buffer(png_frame)
            #         image.save_png(
            #             "user://video_records/temp/%s_%d.png" % [current_title, frame_ind]
            #         )
            #         frame_id += 1
            # video_frames.clear()

            # 调用ffmpeg生成视频
            var dir = ProjectSettings.globalize_path("user://video_records/temp/")
            var outdir = ProjectSettings.globalize_path("user://video_records/")
            ffmpeg_pid = OS.create_process(ffmpeg_path, ["-f", "image2", "-r", "30", "-i", dir + current_title +"_%d.png", outdir + "%s.mp4"%current_title])

            ffmpeg_started = true
            frame_id = 0
        else:
            # 开始录制后，将bufferA_viewport更新模式改为always
            canvas_region.bufferA_viewport.set_update_mode(SubViewport.UPDATE_ALWAYS) 
var frame_id := 0
var video_frames = []


func _ready():
    ffmpeg_path = ProjectSettings.globalize_path("res://vendor/ffmpeg/bin/ffmpeg.exe")
    settings = Helper.load_settings()
    
    # 信号
    canvas_region.full_screen_btn.pressed.connect(on_full_screen_btn_pressed)
    canvas_region.screen_shot_btn.pressed.connect(on_screen_shot_btn_pressed)
    canvas_region.record_video_btn.pressed.connect(on_record_video_btn_pressed)
    EventBus.text_changed.connect(on_project_changed)
    EventBus.texture_changed.connect(on_project_changed)
    EventBus.jfa_to_channel_committed.connect(func (tex): canvas_region.texture_channel_4.texture = tex)
    
    # 语言
    TranslationServer.set_locale(settings["locale"])

    # 设置菜单栏
    file_menu.get_popup().add_item(tr("OPEN"), 0, KEY_MASK_CTRL | KEY_O)
    file_menu.get_popup().add_item(tr("SAVE"), 1, KEY_MASK_CTRL | KEY_S)
    file_menu.get_popup().add_item(tr("SAVE_AS"), 4, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
    file_menu.get_popup().add_item(tr("LOAD_TEMPLATE"), 2, KEY_MASK_CTRL | KEY_R)
    file_menu.get_popup().add_item(tr("QUIT"), 3, KEY_MASK_CTRL | KEY_Q)
    file_menu.get_popup().id_pressed.connect(on_file_id_pressed)
    
    edit_menu.get_popup().add_item(tr("COMMENT"), 0, KEY_MASK_CTRL | KEY_SLASH)
    edit_menu.get_popup().add_item(tr("COPYDOWN"), 1, KEY_MASK_ALT | KEY_MASK_SHIFT | KEY_DOWN)
    # edit_menu.get_popup().add_item("跳到行尾加分号", 2, KEY_SEMICOLON)
    edit_menu.get_popup().add_item(tr("ADD_CODE_REGION"), 3, KEY_MASK_ALT | KEY_R)
    edit_menu.get_popup().add_item(tr("MOVE_UP"), 4, KEY_MASK_ALT | KEY_UP)
    edit_menu.get_popup().add_item(tr("MOVE_DOWN"), 5, KEY_MASK_ALT | KEY_DOWN)
    edit_menu.get_popup().id_pressed.connect(on_edit_id_pressed)

    help_menu.get_popup().add_item(tr("OPEN_USER"), 1)
    help_menu.get_popup().add_item(tr("JFA_GEN"), 2)
    help_menu.get_popup().add_item(tr("ABOUT"), 0)
    help_menu.get_popup().id_pressed.connect(on_help_id_pressed)
    var language_submenu = PopupMenu.new()
    help_menu.get_popup().add_child(language_submenu)
    help_menu.get_popup().add_submenu_item(tr("LANGUAGE"), language_submenu.name, 3)
    language_submenu.add_item(tr("ZH"), 0)
    language_submenu.add_item(tr("EN"), 1)
    language_submenu.id_pressed.connect(func (id):
        var lang := "en"
        match id:
            0:
                lang = "zh"
            1:
                lang = "en"
        settings["locale"] = lang
        Helper.save_settings(settings)
        get_tree().reload_current_scene()
    )

    # 加载基础模板
    if FileAccess.file_exists(TEMP_GDSHADER_FILEPATH):
        load_shader_text(TEMP_GDSHADER_FILEPATH)
    else:
        load_shader_text(SHADER_TEMPLATE_FILEPATH)
    

@warning_ignore("integer_division")
func _process(_delta):
    if dragging:
        var new_pos = DisplayServer.mouse_get_position() - drag_offset
        get_window().position = new_pos

    if video_recording_flag:
        await RenderingServer.frame_post_draw
        # IO瓶颈 get_image()
        Helper.save_png(
            canvas_region.get_current_texture().get_image(), 
            "user://video_records/temp", "%s_%d.png" % [current_title, frame_id / 2]
        )
        # video_frames.append(canvas_region.get_current_texture(true).get_image().save_png_to_buffer())
        frame_id += 1
        if frame_id > 600:
            video_recording_flag = false
    
    if ffmpeg_started:
        if not OS.is_process_running(ffmpeg_pid):
            Helper.clear_dir("user://video_records/temp/")
            Logger.debug("Clear Dir")
            ffmpeg_started = false
            ffmpeg_pid = -5


func on_project_changed():
    editor_region.update_title(current_title + " *")
    

#region Basic File Save & Load
func save_file():
    editor_region.update_title(current_title)
    editor_region.update_text()
    save_shader_text(current_filepath)
    
    if editor_region.glsl_grammar_check():
        sync_shader_text()


func save_file_as():
    editor_region.update_text()
    save_file_dialog.popup()
    
    if editor_region.glsl_grammar_check():
        sync_shader_text()


func load_file():
    open_file_dialog.popup()
    

func save_shader_text(path: String):
    var project := GodotShaderToyProject.new()
    project.save(
        editor_region.common_text,
        editor_region.image_text,
        canvas_region.get_textures()
    )
    ResourceSaver.save(project, path)


func load_shader_text(path: String):
    var project = load(path) as GodotShaderToyProject
    editor_region.set_editor(project)
    canvas_region.set_textures(project)
    sync_shader_text()


func sync_shader_text():
    #Logger.debug(editor_region.get_shader_text())
    canvas_region.update_canvas_shader(editor_region.get_shader_text(true))
#endregion


func close():
    get_tree().quit()

func toggle_fullscreen():
    #FIXME 有时候能完全全屏，有时候会保留底边栏?
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_top_bar_gui_input(event:InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        event = event as InputEventMouse
        dragging = event.is_pressed()

        if dragging:
            drag_offset = DisplayServer.mouse_get_position() - get_window().position
        else:
            dragging = false


#region MenuBar
func on_file_id_pressed(id: int):
    match id:
        0: open_file_dialog.popup()
        1: save_file()
        4: save_file_as()
        2:
            load_shader_text(SHADER_TEMPLATE_FILEPATH)
            current_filepath = TEMP_GDSHADER_FILEPATH
        3: close()

func on_edit_id_pressed(id: int):
    match id:
        0: editor_region.shader_edit.comment_action()
        1: editor_region.shader_edit.copydown_action()
        # 2: editor_region.shader_edit.jump_to_end_action()
        3: editor_region.shader_edit.add_code_region_action()
        4: editor_region.shader_edit.move_line_action(-1)
        5: editor_region.shader_edit.move_line_action(1)

func on_help_id_pressed(id: int):
    match id:
        0: pass
        1: OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"))
        2: popup_layer.show()

func _on_save_file_dialog_file_selected(path):
    current_filepath = path
    save_shader_text(current_filepath)

func _on_open_file_dialog_file_selected(path):
    current_filepath = path
    load_shader_text(current_filepath)
#endregion

#region Quit Canvas Fullscreen
func _on_panel_gui_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        canvas_full_screen_flag = false


func _input(event):
    if event is InputEventKey and event.keycode == KEY_F12 and event.is_pressed():
        toggle_fullscreen()
        
    if canvas_full_screen_flag and event is InputEventKey and event.keycode == KEY_ESCAPE:
        canvas_full_screen_flag = false
#endregion

#region Buttons
func on_full_screen_btn_pressed():
    canvas_full_screen_flag = true

func on_screen_shot_btn_pressed():
    canvas_region.bufferA_viewport.set_update_mode(SubViewport.UPDATE_ONCE) # 设置更新模式为ONCE
    await get_tree().process_frame # 等一帧再保存
    await RenderingServer.frame_post_draw
    
    Helper.save_png(
        canvas_region.get_current_texture(true).get_image(), 
        "user://canvas_screenshot", current_title + ".png"
    )

func on_record_video_btn_pressed():
    video_recording_flag = !video_recording_flag
    
func _on_close_pressed():
    close()

func _on_max_pressed():
    toggle_fullscreen()

func _on_min_pressed():
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
#endregion
