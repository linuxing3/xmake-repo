package('glfw3webgpu')
set_description('An extension for the GLFW library for using WebGPU native.')
set_homepage('https://github.com/eliemichel/glfw3webgpu')
set_license('MIT')

add_urls('https://github.com/eliemichel/glfw3webgpu.git')
add_versions('1.1.0', '45d15f99a260fc8aeef6abd04408278163bbb08d')

add_deps('wgpu-native', 'glfw-walnut')

if is_plat('macosx', 'iphoneos') then
    add_frameworks('Metal', 'Foundation')
end

on_install('windows|x64', 'windows|x86', 'linux|x86_64', 'macosx|x86_64', 'macosx|arm64', function(package)
    if package:is_plat('macosx', 'iphoneos') then
        os.mv('glfw3webgpu.c', 'glfw3webgpu.m')
    end
    io.writefile(
        'xmake.lua',
        [[
            add_rules("mode.debug", "mode.release")

            add_requires("wgpu-native", "glfw-walnut")

            target("glfw3webgpu")
                set_kind("$(kind)")
                set_languages("c11")
                add_headerfiles("glfw3webgpu.h")
                
                add_mxflags("-fno-objc-arc")
                
                add_packages("wgpu-native")
                add_packages("glfw-walnut")
                add_defines("WEBGPU_BACKEND=WGPU")
                
                if is_plat("iphoneos", "macosx") then
                    add_frameworks("Metal", "Foundation")
                    add_files("glfw3webgpu.m")
                else
                    add_files("glfw3webgpu.c")
                end
                
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]]
    )

    import('package.tools.xmake').install(package)
end)

on_test(function(package)
    assert(package:has_cfuncs('glfwGetWGPUSurface', { includes = 'glfw3webgpu.h' }))
end)
