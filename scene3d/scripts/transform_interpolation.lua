--
-- Smoothly interpolated movement of your game objects.
--
-- Usage:
-- ... WIP ...
--

-- Defold 1.3.1 and newer (https://forum.defold.com/t/defold-1-3-1-beta/70594).
-- ^^^^^^^^^^^^^^^^^^^^^^
--
-- The `update` function is called on scripts every frame just after inputs are processed by
-- Defold and before the screen is rendered. If `vsync` is disabled, when one frame is completed, 
-- Defold will immediately start on the next one, therefore attaining the highest possible framerate.
-- Since hardware and the complexity of each frame varies, the frame rate is never constant. Even
-- with `vsync` enabled, causing Defold to try to match a specific frame rate, it is not truly
-- constant. Because of this, `update` can be called any number of times per second.
--
-- The `fixed update` is called on scripts each time the physics simulation is progressed.
-- `fixed update` and physics loop is synchronous, and does not occur on a separate thread.
--
-- The order of updates:
--  - frame 1: update
--  - frame 1: fixed update
--  - frame 2: update
--  - frame 2: fixed update
--  - frame 3: update
--  - frame 3: fixed update
--  - frame 4: update
--  - frame 5: update
--  - frame 5: fixed update
--  - frame 5: fixed update
--  - frame 6: update
--  - frame 6: fixed update
--  - frame 7: update
--  - frame 7: fixed update
--  - frame 8: update
--  - frame 8: fixed update
--  - frame 9: update
--  - frame 9: fixed update
--  - frame 10: update
--  - frame 10: fixed update
--  - frame 11: update
--  - frame 12: update
--  - frame 12: fixed update
--  - frame 12: fixed update
--  - frame 13: update
--  - frame 13: fixed update
--

local math3d = require("scene3d.helpers.math3d")

-- DEBUG
local render3d = require("scene3d.render.render3d")

local M = {}

function M.init(t)
    assert(type(t.object_id) ~= "nil")

    local dt = t.fixed_dt or 1 / math.max(1, tonumber(sys.get_config("engine.fixed_update_frequency", 60)))
    M.start_frame(t, dt)

    return t
end

-- function M.set_time(t)
--     t.set_time = socket.gettime()
-- end

-- Call it in fixed_update()
function M.start_frame(t, dt)
    -- t.start_time = socket.gettime() -- #1: not t.dirty and socket.gettime() or t.start_time
    t.start_time = not t.dirty and socket.gettime() or t.start_time
    t.fixed_dt = dt

    -- DEBUG
    -- if t.start_rotation then
    --     print(render3d.frame_num .. string.format(": start_frame BEFORE euler y %.02f, cur %.02f", math3d.euler_y(t.start_rotation), math3d.euler_y(t.rotation)))
    -- end

    -- #2:
    if t.continuous_mode and t.position and t.rotation then
        t.start_position = t.position
        t.start_rotation = t.rotation
    else
        t.start_position = go.get_position(t.object_id)
        t.start_rotation = go.get_rotation(t.object_id)
        if t.apply_transform then
            t.start_position, t.start_rotation = t:apply_transform(t.start_position, t.start_rotation)
        end
    end

    -- DEBUG
    -- print(render3d.frame_num .. string.format(": start_frame euler y %.02f", math3d.euler_y(t.start_rotation)))

    t.dirty = true
end

-- Call it in update() or late_update()
function M.interpolate(t)
    if t.dirty then
        t.last_position = go.get_position(t.object_id)
        t.last_rotation = go.get_rotation(t.object_id)
        if t.apply_transform then
            t.last_position, t.last_rotation = t:apply_transform(t.last_position, t.last_rotation)
        end
        t.dirty = false

        -- DEBUG
        -- print(render3d.frame_num .. string.format(": dirty, last euler y %.02f", math3d.euler_y(t.last_rotation)))
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