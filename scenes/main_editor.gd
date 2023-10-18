extends CodeEdit

const shader_highlight_file = "res://resources/syntax_highlighter/shader_highlight.json"
const snippets_file = "res://resources/syntax_highlighter/shader_highlight.json"


func _ready():
    var json_dict = load_json_file(shader_highlight_file)
    print(json_dict.keys())
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
            print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
    else:
        print("File not exists: %s" % filepath)


func get_current_word():
    var current_line := get_line(get_caret_line())
    return current_line.substr(0, get_caret_column()).split(" ")[-1]


func update_current_completion_options(word: String):
    print("current word: ", word)
    if word == "":
        print(get_code_completion_options())
    else:
        add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, "hell", "hello", Color.GRAY)
        add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, "worl", "world", Color.GRAY)
        update_code_completion_options(true)


func _on_code_completion_requested():
    print("Code completion Requested")


func _on_text_changed():
    # print(text)
    print(get_caret_line(), ":", get_caret_column())
    update_current_completion_options(get_current_word())
