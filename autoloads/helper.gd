extends Node

const SETTINGS_FILEPATH = "user://config.json"
const DEFAULT_SETTINGS_FILEPATH = "res://resources/config.json"

var shader_var_types := [
    "bool","bvec2","bvec3","bvec4",
    "int","ivec2","ivec3","ivec4",
    "uint","uvec2","uvec3","uvec4",
    "float","vec2","vec3","vec4",
    "mat2","mat3","mat4",
    "sampler2D","isampler2D","usampler2D",
    "sampler2DArray","isampler2DArray","usampler2DArray",
    "sampler3D","isampler3D","usampler3D",
    "samplerCube","samplerCubeArray"]


func load_json_file(filepath: String):
    if FileAccess.file_exists(filepath):
        var json_string = FileAccess.get_file_as_string(filepath)
        var json = JSON.new()
        var error = json.parse(json_string)
        if error == OK:
            return json.data
        else:
            Logger.error("JSON Parse Error: " + json.get_error_message() + " in " + json_string + " at line " + json.get_error_line())
    else:
        Logger.error("File not exists: %s" % filepath)


func save_settings(dict: Dictionary):
    var json_string = JSON.stringify(dict)
    FileAccess.open(SETTINGS_FILEPATH, FileAccess.WRITE).store_string(json_string)


func load_settings() -> Dictionary:
    if not FileAccess.file_exists(SETTINGS_FILEPATH):
        return load_json_file(DEFAULT_SETTINGS_FILEPATH)
    return load_json_file(SETTINGS_FILEPATH)


func search_func_and_var_name(text: String) -> Array:
    var variable_regex = RegEx.new()
    var function_regex = RegEx.new()
    var macro_regex = RegEx.new()
    
    var type_def = "(" + "|".join(shader_var_types) + ")"
    
    variable_regex.compile(type_def + "\\s*(\\w+)\\s*(;|=)")
    function_regex.compile(type_def + "\\s*(\\w+)\\s*\\(.*\\)\\s*\\{")
    macro_regex.compile("#define\\s+(\\w+)")
    
    var ret_arr1 = variable_regex.search_all(text)
    var ret_arr2 = function_regex.search_all(text)
    var ret_arr3 = macro_regex.search_all(text)
    
    var ret := []
    # 0 为匹配到的完整字符串。之后的才是对应的group序号。
    for r in ret_arr1:
        ret.append([r.get_string(2), r.get_start(2)])
    for r in ret_arr2:
        ret.append([r.get_string(2), r.get_start(2)])
    for r in ret_arr3:
        ret.append([r.get_string(1), r.get_start(2)])
    #Logger.debug("Defined", ret)
    return ret


func load_external_image(filepath:String) -> ImageTexture:
    var image = Image.load_from_file(filepath)
    var texture = ImageTexture.create_from_image(image)
    return texture


func save_png(img: Image, dir: String, file: String):
    if not DirAccess.dir_exists_absolute(dir):
        DirAccess.make_dir_recursive_absolute(dir)

    if not dir.ends_with("/"):
        dir += "/"
        
    img.save_png(dir + file)


func clear_dir(path: String):
    if not path.ends_with("/"):
        path += "/"

    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var filename = dir.get_next()
        while filename != "":
            if dir.current_is_dir():
                clear_dir(path + filename)
            else:
                dir.remove(path + filename)
                Logger.debug(path + filename)
            filename = dir.get_next()
    else:
        Logger.warn("尝试访问路径时出错: %s" % path)
