class_name JFA
extends Node

@export var mat: ShaderMaterial


func create_render_target():
    var viewport = SubViewport.new()
    add_child(viewport)
    viewport.disable_3d = true
    # viewport.use_hdr_2d = false #TODO true: 可以RGBA16F的格式保存帧缓冲
    var texture_rect = TextureRect.new()
    viewport.add_child(texture_rect)
    # texture_rect.anchors_preset = Control.PRESET_FULL_RECT
    return [viewport, texture_rect]


func do_jfa(path: String):
    var input_texture = Helper.load_external_image(path)
    var bufferA = create_render_target()
    var bufferB = create_render_target()

    bufferA[0].set_size(input_texture.get_size())
    bufferB[0].set_size(input_texture.get_size())
    bufferA[1].texture = bufferB[0].get_texture()
    bufferB[1].texture = bufferA[0].get_texture()

    bufferA[1].material = mat.duplicate()
    bufferB[1].material = mat.duplicate()
    bufferA[1].material.set_shader_parameter("inTex", input_texture)

    # 第0帧 读取输入并预处理
    # 1~12帧 JFA
    # 13,14帧 JFA+2 减少错误率
    # 13~24帧 JFA^2 减少错误率
    await get_tree().process_frame
    for i in 25: 
        await get_tree().process_frame
        bufferA[1].material.set_shader_parameter("iFrame", i)
        bufferB[1].material.set_shader_parameter("iFrame", i)

        if i % 2 == 0:
            bufferA[0].set_update_mode(SubViewport.UPDATE_ONCE)
            # await RenderingServer.frame_post_draw
            # bufferA[0].get_texture().get_image().save_png("res://jfa_%d.png" % i)
        else:
            bufferB[0].set_update_mode(SubViewport.UPDATE_ONCE)
            # await RenderingServer.frame_post_draw
            # bufferB[0].get_texture().get_image().save_png("res://jfa_%d.png" % i)

    await RenderingServer.frame_post_draw
    # 导出的结果图在使用时需要指定filter_nearest，因为存的是离当前像素最近的种子的坐标位置。插值会在边界处引入瑕疵
    # bufferA[0].get_texture().get_image().save_png("res://jfa_result.png")
    return bufferA[0].get_texture().get_image()
