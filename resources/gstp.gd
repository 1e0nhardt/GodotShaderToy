class_name GodotShaderToyProject
extends Resource

@export var image_text: String
@export var common: String
@export var channel0: Texture2D
@export var channel1: Texture2D
@export var channel2: Texture2D
@export var channel3: Texture2D


func save(c: String, i: String, chs: Array[Texture2D]):
    common = c
    image_text = i
    channel0 = chs[0]
    channel1 = chs[1]
    channel2 = chs[2]
    channel3 = chs[3]
