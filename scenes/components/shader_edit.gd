class_name ShaderEdit
extends CodeEdit

const shader_highlight_file = "res://assets/syntax_highlighter/shader_highlight.json"
const snippets_file = "res://assets/snippets/godot_shader_snippet.json"

@onready var error_output = %ErrorOutput
@onready var panel_container = $PanelContainer

var snippet_dict = Helper.load_json_file(snippets_file)
var shortcut_on_flag := false
var defined_func_var_macro := []
var defined_func_var_macro_in_common := []
var find_first_nonspace_regex := RegEx.new()
var text_changed_flag := false

func _ready():
    find_first_nonspace_regex.compile("\\w")

    # 语法高亮
    var json_dict = Helper.load_json_file(shader_highlight_file)

    for color_string in json_dict:
        if not json_dict[color_string] is Array:
            continue

        for keyword in json_dict[color_string]:
            syntax_highlighter.add_keyword_color(keyword, Color(color_string, 1.0))

    # 注释
    syntax_highlighter.add_color_region("//", "", Color("808183", 1.0))
    # create_code_region() 需要
    add_comment_delimiter("//", "")


#region error message
func show_error_output(msg: String):
    error_output.text = msg
    panel_container.show()


func hide_error_output():
    panel_container.hide()
#endregion


func get_current_word():
    var current_line := get_line(get_caret_line())
    if current_line.ends_with(" "):
        return " "
    return current_line.substr(0, get_caret_column()).split(" ")[-1].split("(")[-1]


func search_defined_symbols():
    defined_func_var_macro = Helper.search_func_and_var_name(text)


func update_current_completion_options(word: String):
    # Logger.info("current word: ", word)
    if word == "" or word == " ":
        update_code_completion_options(false)
        return
        
    search_defined_symbols()
    
    for key in snippet_dict["keywords"]:
        if key.matchn(word + "*"):
            add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, key, key, Color.GRAY)
    
    for key in defined_func_var_macro + defined_func_var_macro_in_common:
        if key[0].matchn(word + "*"):
            add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, key[0], key[0], Color.GRAY)
    
    for key in snippet_dict["snippets"]:
        if key.matchn(word + "*"):
            add_code_completion_option(CodeCompletionKind.KIND_FUNCTION, key + "□", snippet_dict["snippets"][key], Color.GRAY)
    
    update_code_completion_options(true)


func _on_text_changed():
    EventBus.text_changed.emit()
    text_changed_flag = true
    #Logger.debug("Caret Word", get_word_under_caret()) 
    update_current_completion_options(get_current_word())
    #Logger.debug("Func&Var", Helper.search_func_and_var_name(text))


func _on_caret_changed():
    if not text_changed_flag:
        update_code_completion_options(false)
    else:
        text_changed_flag = false


func _on_focus_entered():
    shortcut_on_flag = true


func _on_focus_exited():
    shortcut_on_flag = false


func _on_gui_input(event:InputEvent):
    if not shortcut_on_flag:
        return

    if event is InputEventKey:
        if event.get_keycode_with_modifiers() == KEY_SEMICOLON and event.pressed:
            jump_to_end_action()


func comment_action():
    var raw_caret_column = get_caret_column()
    if has_selection():
        var selection_range := [
            get_selection_from_line(), 
            get_selection_from_column(),
            get_selection_to_line(),
            get_selection_to_column()
        ]
        deselect()
        for i in range(selection_range[0], selection_range[2] + 1):
            set_caret_line(i)
            
            if get_line(i).begins_with("//"):
                set_caret_column(2)
                backspace()
                backspace()
            else:
                set_caret_column(0)
                insert_text_at_caret("//")
        select(
            selection_range[0],
            selection_range[1],
            selection_range[2],
            selection_range[3] + 2
        )
        raw_caret_column = 999
    else:
        var current_line_text = get_line(get_caret_line())
        if current_line_text.lstrip(" ").begins_with("//"):
            set_caret_column(current_line_text.find("//") + 2)
            backspace()
            backspace()
            raw_caret_column -= 2
        else:
            var indent_length = find_first_nonspace_regex.search(current_line_text).get_start()
            set_caret_column(indent_length)
            insert_text_at_caret("//")
            raw_caret_column += 2
    set_caret_column(raw_caret_column)

func copydown_action():
    duplicate_lines()

func jump_to_end_action():
    # 按分号时直接跳转到行尾
    if get_line(get_caret_line()).length() != get_caret_column():
        set_caret_column(get_line(get_caret_line()).length())

func add_code_region_action():
    #FIXME 加了立即撤回，会留下一行gutter。
    if has_selection():
        create_code_region()

func move_line_action(direction: int):
    var current_line = get_caret_line()
    swap_lines(current_line, current_line+direction)
    set_caret_line(current_line+direction)


func _on_symbol_lookup(_symbol, _line, _column):
    #Logger.debug("Symbol", symbol)
    #for key in defined_func_var_macro:
        #if key[0] == symbol:
            #Logger.debug("Def Loc", key[1])
            #Logger.debug(text.substr(0, key[1]))
    #Logger.debug("Line", line)
    #Logger.debug("Column", column)
    pass


func _on_symbol_validate(symbol):
    #Logger.debug("Symbol", symbol)
    for key in defined_func_var_macro:
        if key[0] == symbol:
            set_symbol_lookup_word_as_valid(true)
