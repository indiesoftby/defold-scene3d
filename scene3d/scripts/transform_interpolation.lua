--
-- Smoothly interpolated movement of your game objects
--
-- Usage:
-- TODO :)
--

local math3d = require("scene3d.helpers.math3d")

-- DEBUG
-- local render3d = require("scene3d.render.render3d")

local M = {}

function M.init(t)
    assert(type(t) == "table")
    assert(type(t.obj_id) ~= "nil")

    local dt = t.fixed_dt or 1 / math.max(1, tonumber(sys.get_config("engine.fixed_update_frequency", 60)))
    M.start_frame(t, dt)

    return t
end

-- Call it in fixed_update()
function M.start_frame(t, dt)
    t.start_time = socket.gettime() -- #1: not t.dirty and socket.gettime() or t.start_time
    t.fixed_dt = dt

    -- #2:
    -- t.start_position = go.get_position(t.obj_id)
    -- t.start_rotation = go.get_rotation(t.obj_id)

    -- #3:
    t.start_position = t.position or go.get_position(t.obj_id)
    t.start_rotation = t.rotation or go.get_rotation(t.obj_id)

    t.dirty = true
end

-- Call it in update() or late_update()
function M.interpolate(t)
    if t.dirty then
        t.last_position = go.get_position(t.obj_id)
        t.last_rotation = go.get_rotation(t.obj_id)
        t.dirty = false
    end

    local time = socket.gettime()
    t.update_time = time

    local interpolation_factor = math3d.clamp01((time - t.start_time) / t.fixed_dt)

    -- DEBUG
    -- print(render3d.frame_num .. string.format(": transform update, factor %.03f [%.03f -> %.03f], fixed dt %.03f", interpolation_factor, t.start_time, time, t.fixed_dt))

    t.position = vmath.lerp(interpolation_factor, t.start_position, t.last_position)
    t.rotation = vmath.slerp(interpolation_factor, t.start_rotation, t.last_rotation)
end

return M