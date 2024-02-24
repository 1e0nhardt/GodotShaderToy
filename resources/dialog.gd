class_name Dialog
extends RefCounted

var full_text: String


func read_script(filepath: String):
    if not FileAccess.file_exists(filepath):
        Logger.error("%s is not exists!" % filepath)
    
    full_text = FileAccess.get_file_as_string(filepath)


func parse() -> Array[DialogNode]:
    return []