extends CodeEdit

const shader_highlight_file = "res://resources/syntax_highlighter/shader_highlight.json"
const snippets_file = "res://resources/snippets/godot_shader_snippet.json"

var snippet_dict = load_json_file(snippets_file)
var shortcut_on_flag = false

class TextLines:
    var _lines = []

    func update(raw_text: String):
        _lines = raw_text.split("\n")

    func comment_line(index: int):
        if _lines[index].strip_edges().begins_with("//"):
            _lines[index] = _lines[index].replace("//", "")
        else:
            _lines[index] = "//" + _lines[index]

    func comment_lines(from: int, to: int):
        for i in range(from, to + 1):
            comment_line(i)

    func copy_down(index: int):
        _lines[index] = "\n".join([_lines[index], _lines[index]])

    func get_text():
        return "\n".join(_lines)

var lines = TextLines.new()


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


func _on_focus_entered():
    shortcut_on_flag = true


func _on_focus_exited():
    shortcut_on_flag = false


func _on_gui_input(event:InputEvent):
    if not shortcut_on_flag:
        return

    if event is InputEventKey:
        lines.update(text)

        if event.get_keycode_with_modifiers() == KEY_MASK_CTRL | KEY_SLASH and event.pressed:
            var raw_caret_line = get_caret_line()
            if has_selection():
                # Logger.debug("Selection Line", get_selection_from_line())
                # Logger.debug("Selection to Line", get_selection_to_line())
                lines.comment_lines(get_selection_from_line(), get_selection_to_line())
            else:
                lines.comment_line(raw_caret_line)
            text = lines.get_text()
            set_caret_line(raw_caret_line, true, false)

        elif event.get_keycode_with_modifiers() == KEY_MASK_ALT | KEY_MASK_SHIFT | KEY_DOWN and event.pressed:
            var raw_caret_line = get_caret_line()
            lines.copy_down(raw_caret_line)
            text = lines.get_text()
            set_caret_line(raw_caret_line + 1, false)
