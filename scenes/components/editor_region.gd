class_name EditorRegion
extends VBoxContainer

const TEMP_GLSL_SHADER_FILEPATH = "user://temp.frag"

@onready var shader_edit: ShaderEdit = %ShaderEdit
@onready var title_label: Label = %TitleLabel
@onready var common: Button = %Common
@onready var image: Button = %Image

var active_style = preload("res://themes/button_activate.tres")
var deactive_style = preload("res://themes/button_deactivate.tres")
var activate_index := 1 # 0: Common, 1: Image
var common_text: String = ""
var image_text: String = ""
var glslang_path: String
var glsl_error_infomation = []
var current_text: String:
    get:
        return image_text if activate_index == 1 else common_text


func _ready():
    common.pressed.connect(on_common_pressed)    
    image.pressed.connect(on_image_pressed)   
    
    image.set("theme_override_styles/normal", active_style)
    image.set("theme_override_styles/focus", active_style)
    common.set("theme_override_styles/normal", deactive_style)
    common.set("theme_override_styles/focus", deactive_style) 
    
    glslang_path = ProjectSettings.globalize_path("res://vendor/glslang/bin/glslang.exe")


func set_editor(project: GodotShaderToyProject):
    common_text = project.common
    shader_edit.defined_func_var_macro_in_common = Helper.search_func_and_var_name(common_text)
    image_text = project.image_text
    shader_edit.text = current_text


func get_shader_text(full=false) -> String:
    if activate_index == 0 and not full:
        return common_text
    
    # 先处理注释行
    var reg = RegEx.new()
    reg.compile("//.*\n")
    var common_in_one_line = reg.sub(common_text, "", true)
    common_in_one_line = "".join(common_in_one_line.split("\n"))
    return image_text.insert(image_text.find("//END") + 5, "\n" + common_in_one_line)


func update_title(s):
    title_label.text = s
    

#region Glsl Grammar Check
func converter(godot_shader_string: String):
    var glsl_shader_head = "#version 300 es\n#ifdef GL_ES\nprecision mediump float;\n#endif\nuniform float u_time;uniform vec2 u_resolution;uniform sampler2D TEXTURE;\nconst float PI = 3.1415926535;const float TAU = 3.1415926535;const float E = 2.718281828459045;out vec4 fragColor;\n"
    var glsl_shader_head_common = "#version 300 es\n#ifdef GL_ES\nprecision mediump float;\n#endif\nuniform float u_time;uniform vec2 u_resolution;uniform sampler2D TEXTURE;\nconst float PI = 3.1415926535;const float TAU = 3.1415926535;const float E = 2.718281828459045;out vec4 fragColor;\n"
    godot_shader_string = godot_shader_string.substr(godot_shader_string.find("//END") + 5)
    godot_shader_string = godot_shader_string.replace("void fragment()", "void main()")
    # godot_shader_string = godot_shader_string.replace("#include \"res://resources/my_functions.gdshaderinc\"", shader_include_content)
    # godot_shader_string = godot_shader_string.replace("uniform vec2 mouse_pos;", "uniform vec2 u_mouse;")
    # godot_shader_string = godot_shader_string.replace("mouse_pos", "u_mouse")
    #godot_shader_string = godot_shader_string.replace("texture(", "texture2D(")
    godot_shader_string = godot_shader_string.replace("TIME", "u_time")
    godot_shader_string = godot_shader_string.replace("UV", "gl_FragCoord.xy")
    godot_shader_string = godot_shader_string.replace("COLOR", "fragColor")
    godot_shader_string = godot_shader_string.replace("FRAGCOORD", "gl_FragCoord")
    godot_shader_string = godot_shader_string.replace("VERTEX", "gl_Position")
    godot_shader_string = godot_shader_string.replace("POINT_SIZE", "gl_PointSize")
    godot_shader_string = godot_shader_string.replace("POINT_COORD", "gl_PointCoord")
    godot_shader_string = godot_shader_string.replace("FRONT_FACING", "gl_FrontFacing")
    godot_shader_string = godot_shader_string.replace("SCREEN_PIXEL_SIZE", "(1./u_resolution)")
    godot_shader_string = godot_shader_string.replace("TEXTURE_PIXEL_SIZE", "(1./u_resolution)")
    # 去掉godot特有的纹理声明
    var regex = RegEx.new()
    regex.compile("uniform\\s+[i|u]?sampler\\w*\\s+\\w*(:.*)+;")
    var ret = regex.search_all(godot_shader_string)
    for r in ret:
        godot_shader_string = godot_shader_string.replace(r.get_string(1), "")
    
    if activate_index == 0:
        return glsl_shader_head_common + godot_shader_string
    return glsl_shader_head + godot_shader_string


func glsl_grammar_check() -> bool:
    """返回false表示有语法错误"""
    var ft = FileAccess.open(TEMP_GLSL_SHADER_FILEPATH, FileAccess.WRITE)
    var converted_text = converter(get_shader_text())
    ft.store_string(converted_text)
    ft.close()

    OS.execute(glslang_path, [ProjectSettings.globalize_path(TEMP_GLSL_SHADER_FILEPATH)], glsl_error_infomation, true)
    var error_flag = (glsl_error_infomation[0] != "")
    if error_flag:
        var error_msg: String = glsl_error_infomation[0];
        error_msg = error_msg.substr(error_msg.find('\n'))
        shader_edit.show_error_output(error_msg.strip_edges())
    else:
        shader_edit.hide_error_output()
    glsl_error_infomation = []
    return !error_flag
#endregion


func on_common_pressed():
    if activate_index == 0:
        return

    activate_index = 0
    image.set("theme_override_styles/normal", deactive_style)
    image.set("theme_override_styles/focus", deactive_style)
    common.set("theme_override_styles/normal", active_style)
    common.set("theme_override_styles/focus", active_style)
    image_text = shader_edit.text
    shader_edit.text = common_text


func on_image_pressed():
    if activate_index == 1:
        return
    
    activate_index = 1
    image.set("theme_override_styles/normal", active_style)
    image.set("theme_override_styles/focus", active_style)
    common.set("theme_override_styles/normal", deactive_style)
    common.set("theme_override_styles/focus", deactive_style)
    common_text = shader_edit.text
    shader_edit.text = image_text
    shader_edit.defined_func_var_macro_in_common = Helper.search_func_and_var_name(common_text)


func update_text():
    if activate_index == 0:
        common_text = shader_edit.text
    elif activate_index == 1:
        image_text = shader_edit.text
