extends CodeEdit

const shader_highlight_file = "res://resources/syntax_highlighter/shader_highlight.json"
const snippets_file = "res://resources/snippets/godot_shader_snippet.json"

var snippet_dict = load_json_file(snippets_file)


func _ready():
    # 语法高亮
    var json_dict = load_json_file(shader_highlight_file)

    for color_string in json_dict:
        if not json_dict[color_string] is Array:
            continue
        
        for keyword in json_dict[color_string]:
            syntax_highlighter.add_keyword_color(keyword, Color(color_string, 1.0))
    
    # 注释
    syntax_highlighter.add_color_region("//", "", Color("808183", 1.0))


func load_json_file(filepath: String):
    if FileAccess.file_exists(filepath):
        var json_string = FileAccess.open(filepath, FileAccess.READ).get_as_text()
        # Retrieve data
        var json = JSON.new()
        var error = json.parse(json_string)
        if error == OK:
            return json.data
        else:
            Logger.error("JSON Parse Error: " + json.get_error_message() + " in " + json_string + " at line " + json.get_error_line())
    else:
        Logger.error("File not exists: %s" % filepath)


func get_current_word():
    var current_line := get_line(get_caret_line())
    return current_line.substr(0, get_caret_column()).split(" ")[-1].split("(")[-1]


func update_current_completion_options(word: String):
    # Logger.info("current word: ", word)
    if word == "":
        return
    else:
        for key in snippet_dict["keywords"]:
            if key.match(word + "*"):
                add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, key, key, Color.GRAY)
        for key in snippet_dict["snippets"]:
            if key.match(word + "*"):
                add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, key + "□", snippet_dict["snippets"][key], Color.GRAY)
        update_code_completion_options(true)


func _on_text_changed():
    # Logger.info(text)
    # Logger.info(get_caret_line(), ":", get_caret_column())
    update_current_completion_options(get_current_word())
    if not name.ends_with("*"):
        name = name + " *"