class_name P5Dialog
extends Control

const CHARACTER_SPRITE_SIZE = Vector2(440, 440)

@export var box_color: Color:
    set(value):
        box_color = value
        set_box_color(value)
@export var border_color: Color:
    set(value):
        border_color = value
        set_border_color(value)

@onready var dialog_node = $DialogNode
@onready var dialog_box = $DialogNode/DialogBox
@onready var dialog_box_border = $DialogNode/DialogBox/DialogBoxBorder
@onready var name_box = $DialogNode/NameBox
@onready var name_box_content = $DialogNode/NameBox/NameBoxContent
@onready var mark_node = $DialogNode/MarkNode
@onready var mark_box = $DialogNode/MarkNode/MarkBox
@onready var mark_box_content = $DialogNode/MarkNode/MarkBox/MarkBoxContent

@onready var name_label: Label = $NameLabel
@onready var text_label: Label = $TextLabel
@onready var contrast_label: Label = %ContrastLabel
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var t := 0.0
var mark_node_origin: Vector2
var mark_node_origin_init: Vector2
var change_target_flag := false
var prev_lines: int
var dialog_font_size: int
var nopass_area_width_init: float

var dialog_box_animation_vertices: Array = [2,3,4,11,12,13,14,5,10]
var dialog_box_border_animation_vertices: Array = [
    1,2,3,8,9,10,
    22,21,20,15,14,13,
    4,19,7,16
]
var name_box_animation_vertices: Array = [1,2,3,4,5,6]
var name_box_content_animation_vertices: Array = [2,3,4,5,6,7]
var dialog_box_right_vertices: Array = [6,7,8,9]
var dialog_box_border_right_vertices: Array = [5,6,17,18]

var box_polygon: PackedVector2Array
var box_border_polygon: PackedVector2Array
var name_polygon: PackedVector2Array
var name_content_polygon: PackedVector2Array

var current_character_name: String

var dialog_visible: bool:
    set(value):
        visible = value
        if not animation_player:
            return

        if value:
            animation_player.play("play_in")
        else:
            animation_player.play("play_out")
    get:
        return visible


func _ready():
    mark_node_origin = Vector2(520, 60)
    mark_node_origin_init = Vector2(520, 60)
    box_polygon = dialog_box.polygon.duplicate()
    box_border_polygon = dialog_box_border.polygon.duplicate()
    name_polygon = name_box.polygon.duplicate()
    name_content_polygon = name_box_content.polygon.duplicate()
    dialog_font_size = text_label.get_theme_font_size("font_size")
    nopass_area_width_init = size.x

    set_box_color(box_color)
    set_border_color(border_color)
    visible = false
    dialog_visible = false

    test_dialog()


func test_dialog():
    set_dialog("雨宫 莲", "心之怪盗团\ntake your heart!", "res://assets/bochi_haha.png")
    get_tree().create_timer(2.0).timeout.connect(func (): dialog_visible = true)
    get_tree().create_timer(4.0).timeout.connect(func (): change_dialog("雨宫 莲", "心之怪盗团哈哈\ntake your heart!", "res://assets/bochi_haha.png"))
    get_tree().create_timer(8.0).timeout.connect(func (): change_dialog("雨宫 莲", "拜访量浮动啊啊浮动啊封顶发等死阿三\ntake your heart!", "res://assets/bochi_haha.png"))
    get_tree().create_timer(12.0).timeout.connect(func (): change_dialog("喜多川 佑介", "心之怪盗懂法团\ntake your heart!", "res://icon.svg"))


func _process(delta):
    t += delta * 1.5
    for v in dialog_box_border_animation_vertices:
        dialog_box_border.polygon[v] = animate_point(box_border_polygon[v], 6, v)
    for v in dialog_box_animation_vertices:
        dialog_box.polygon[v] = animate_point(box_polygon[v], 6, v)
    for v in name_box_animation_vertices:
        name_box.polygon[v] = animate_point(name_polygon[v], 6, v)
    for v in name_box_content_animation_vertices:
        name_box_content.polygon[v] = animate_point(name_content_polygon[v], 6, v+1)
    animate_mark(delta)


func animate_mark(delta: float):
    var curve := triangle_curve(t)
    if curve - triangle_curve(t - delta) < 0 and triangle_curve(t + delta) - curve > 0:
        change_target_flag = not change_target_flag
    var mark_target = Vector2( 8, 2) if change_target_flag else Vector2(4, -6)

    mark_node.position = mark_node_origin + curve * mark_target
    mark_node.scale =  Vector2(1 + curve * 0.2, 1 + curve * 0.2)


func animate_point(point: Vector2, r: float, index: int):
    var curve := triangle_curve(t + index / 2.0)
    return point + curve * Vector2(r / 2.0, ((index % 2) - 0.5) * r)


func triangle_curve(x: float, T=1.0) -> float:
    # 周期为1的三角波
    return abs((fmod(x, T)) * 2.0 * T - T)


func set_box_color(c: Color):
    if not is_node_ready():
        return

    dialog_box.color = c
    name_box.color = c
    mark_box.color = c


func set_border_color(c: Color):
    if not is_node_ready():
        return

    dialog_box_border.color = c
    name_box_content.color = c
    mark_box_content.color = c


func set_character_name(n: String):
    name_label.text = n
    contrast_label.text = n[1]


func set_character_sprite(n: String):
    character_sprite.texture = load(n)
    character_sprite.scale = CHARACTER_SPRITE_SIZE / character_sprite.texture.get_size()


func set_dialog_content(n: String):
    text_label.text = n

    var max_line_length = 0
    var lines = n.split("\n")
    for line in lines:
        if line.length() > 15 and line.length() > max_line_length:
            max_line_length = line.length()

    # Logger.debug("Lines", lines)
    # 只考虑台词有1行或2行的情况
    if lines.size() == 1 and prev_lines != 1:
        box_polygon[6] += Vector2(0, -dialog_font_size)
        box_border_polygon[5] += Vector2(0, -dialog_font_size)
        box_border_polygon[18] += Vector2(0, -dialog_font_size)
        prev_lines = 1
    elif prev_lines == 1:
        box_polygon[6] -= Vector2(0, -dialog_font_size)
        box_border_polygon[5] -= Vector2(0, -dialog_font_size)
        box_border_polygon[18] -= Vector2(0, -dialog_font_size)
        prev_lines = lines.size()

    var text_label_expand_width = 0
    if max_line_length > 15:
        text_label_expand_width = dialog_font_size * (max_line_length - 15)

        for v in dialog_box_right_vertices:
            dialog_box.polygon[v] = box_polygon[v] + Vector2(text_label_expand_width, 0)
        for v in dialog_box_border_right_vertices:
            dialog_box_border.polygon[v] = box_border_polygon[v] + Vector2(text_label_expand_width, 0)

        # Logger.debug("Dialog Size", text_label_expand_width)

    mark_node_origin = mark_node_origin_init + Vector2(text_label_expand_width, 0)


func change_dialog(character_name: String, content: String, sprite_path: String = ""):
    # 切人了
    if current_character_name != character_name:
        current_character_name = character_name
        animation_player.play("play_out")
        await animation_player.animation_finished
        animation_player.play("RESET")
        await animation_player.animation_finished
        set_dialog(character_name, content, sprite_path)
        animation_player.play("play_in")
    else: # 同一个人连续说话
        var tween = create_tween()
        tween.tween_property(text_label, "self_modulate", Color(0,0,0,0), 0.2)
        await tween.finished
        text_label.self_modulate = Color(1,1,1,1)
        set_dialog_content(content)


func set_dialog(character_name: String, content: String, sprite_path: String = ""):
    set_character_name(character_name)
    set_dialog_content(content)
    if sprite_path != "":
        if not FileAccess.file_exists(sprite_path):
            Logger.warn("Character sprite path not exist: %s" % sprite_path)
            return
        set_character_sprite(sprite_path)


func show_once(character_name: String, content: String, duration: float, sprite_path: String = ""):
    set_dialog(character_name, content, sprite_path)
    dialog_visible = true
    get_tree().create_timer(duration).timeout.connect(func (): dialog_visible = false)
