local M = {}

-- Variables
M.debug_text = ""
M.frame_num = 1
M.show_fps = false

M.window_width = tonumber(sys.get_config("display.width", 1920))
M.window_height = tonumber(sys.get_config("display.height", 1080))

-- Constants
local IDENTITY_MAT4 = vmath.matrix4()
M.FORWARD = vmath.vector3(0, 0, -1)
M.RIGHT = vmath.vector3(1, 0, 0)
M.UP = vmath.vector3(0, 1, 0)

-- Camera vars
M.clear_color = vmath.vector4()
M.aspect_ratio = 0
M.fov = 0
M.near = 0
M.far = 0
M.view_position = vmath.vector3()
M.view_world_up = vmath.vector3()
M.view_front = vmath.vector3()
M.view_right = vmath.vector3()
M.view_up = vmath.vector3()

M.viewports = {}

-- Lighting & Fog
M.light_ambient_color = vmath.vector3()
M.light_ambient_intensity = 0
M.light_directional_intensity = 0
M.light_directional_direction = vmath.vector3()
M.fog_intensity = 0
M.fog_range_from = 0
M.fog_range_to = 0
M.fog_color = vmath.vector3()

function M.reset()
    M.clear_color = vmath.vector4(
        sys.get_config("render.clear_color_red", 0),
        sys.get_config("render.clear_color_green", 0),
        sys.get_config("render.clear_color_blue", 0),
        sys.get_config("render.clear_color_alpha", 1))

    M.aspect_ratio = M.window_width/M.window_height
    M.fov = 42.5
    M.near = 0.1
    M.far = 100

    M.viewports = {
        { x = 0, y = 0, w = 1, h = 1 }
    }

    M.view_position = vmath.vector3(0, 0, 0)
    M.view_world_up = M.UP
    M.view_front = vmath.vector3(M.FORWARD)
    M.view_right = vmath.vector3(M.RIGHT)
    M.view_up = vmath.vector3(M.UP)

    M.light_ambient_color = vmath.vector3(1, 1, 1)
    M.light_ambient_intensity = 0.25
    M.light_directional_intensity = 1.25
    M.light_directional_direction = vmath.vector3(-0.43193421279068, -0.86386842558136, -0.259160527674408)

    M.fog_intensity = 1.0
    M.fog_range_from = 50.0
    M.fog_range_to = 100.0
    M.fog_color = vmath.vector3(0.839, 0.957, 0.98)
end

-- Reset variables to default values
M.reset()

-- TODO: test for yaw = 270, pitch = -90
function M.view_from_yaw_pitch(yaw, pitch, viewport)
    viewport = viewport or M

    viewport.camera_yaw = yaw
    viewport.camera_pitch = pitch

    local front = vmath.vector3()
    front.x = math.cos(math.rad(yaw)) * math.cos(math.rad(pitch))
    front.y = math.sin(math.rad(pitch))
    front.z = math.sin(math.rad(yaw)) * math.cos(math.rad(pitch))
    local direction = vmath.normalize(front)

    M.view_direction(direction, viewport)
end

function M.view_from_rotation(quat, viewport)
    viewport = viewport or M

    viewport.view_world_up = M.UP
    viewport.view_front = vmath.rotate(quat, M.FORWARD)
    viewport.view_right = vmath.rotate(quat, M.RIGHT)
    viewport.view_up = vmath.rotate(quat, M.UP)
end

function M.view_direction(direction, viewport)
    viewport = viewport or M

    viewport.view_world_up = M.UP
    viewport.view_front = direction
    -- Re-calculate the Right and Up vector, plus normalize the vectors,
    -- because their length gets closer to 0 the more you look up or down
    viewport.view_right = vmath.normalize(vmath.cross(viewport.view_front, viewport.view_world_up)) 
    viewport.view_up = vmath.normalize(vmath.cross(viewport.view_right, viewport.view_front))
end

function M.update_window(w, h)
    M.window_width = math.max(1, w)
    M.window_height = math.max(1, h)
    M.aspect_ratio = w / h
end

function M.camera_view(viewport)
    if not viewport then
        return vmath.matrix4_look_at(M.view_position, M.view_position + M.view_front, M.view_up)
    else
        return vmath.matrix4_look_at(viewport.view_position, viewport.view_position + viewport.view_front, viewport.view_world_up)
    end
end

function M.camera_perspective(fov, aspect_ratio, near, far)
    return vmath.matrix4_perspective(math.rad(fov or M.fov), aspect_ratio or M.aspect_ratio, near or M.near, far or M.far)
end

function M.inc_frame()
    M.frame_num = M.frame_num + 1
end

function M.debug_log(t)
    M.debug_text = M.debug_text .. tostring(t) .. "   "
end

return M