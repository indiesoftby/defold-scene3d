local M = {}

--
-- Quaternions
--

--- Returns the Euler angle representation of a rotation, in degrees - X.
-- @param q The quaternion in question.
-- @return A new angle.
function M.euler_x(q)
    local t = q.x * q.y + q.z * q.w
    if t > 0.4999 then
        return 0
    elseif t < -0.4999 then
        return 0
    else
        local sqx = q.x * q.x
        local sqz = q.z * q.z
        return math.atan2(2 * q.x * q.w - 2 * q.y * q.z, 1 - 2 * sqx - 2 * sqz) * 57.295779513
    end
end

--- Returns the Euler angle representation of a rotation, in degrees - Y.
-- @param q The quaternion in question.
-- @return A new angle.
function M.euler_y(q)
    local t = q.x * q.y + q.z * q.w
    if t > 0.4999 then
        return 2 * math.atan2(q.x, q.w)
    elseif t < -0.4999 then
        return -2 * math.atan2(q.x, q.w)
    else
        local sqy = q.y * q.y
        local sqz = q.z * q.z
        return math.atan2(2 * q.y * q.w - 2 * q.x * q.z, 1 - 2 * sqy - 2 * sqz) * 57.295779513
    end
end

--- Returns the Euler angle representation of a rotation, in degrees - Z.
-- @param q The quaternion in question.
-- @return A new angle.
function M.euler_z(q)
    local t = q.x * q.y + q.z * q.w
    if t > 0.4999 then
        return 90
    elseif t < -0.4999 then
        return -90
    else
        return math.asin(2 * t) * 57.295779513
    end
end

--- Returns the inverse of rotation.
-- https://docs.unity3d.com/ScriptReference/Transform.InverseTransformDirection.html
-- https://forum.unity.com/threads/what-is-the-match-behind-transform-inversetransformdirection-vector3.860068/
-- @param q The quaternion in question.
-- @return A new quaternion.
function M.quat_inv(q)
    local q2 = vmath.quat()
    local num2 = (((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w)
    local num = 1 / num2
    q2.x = -q.x * num
    q2.y = -q.y * num
    q2.z = -q.z * num
    q2.w = q.w * num
    return q2
end

--- Creates a rotation with the specified forward and upwards directions.
-- The output is undefined for parallel vectors.
-- @param forward The forward direction to look toward.
-- @param upwards The direction to treat as up (optional, "+Y" is default).
-- @return A new quaternion.
function M.quat_look_rotation(forward, upwards)
    return scene3d.quat_look_rotation(forward, upwards)
end

--
-- Miscellaneous
--

--- Returns the sign of x.
function M.sign(x)
    return x < 0 and -1 or 1
end

--- Clamps the given x between the given minimum float and maximum float values.
-- @param x The floating point value to restrict inside the range defined by the min and max values.
-- @param min The minimum floating point value to compare against.
-- @param max The maximum floating point value to compare against.
-- @return The float result between the min and max values.
function M.clamp(x, min, max)
    if x < min then
        x = min
    elseif x > max then
        x = max
    end
    return x
end

--- Loops the value t, so that it is never larger than length and never smaller than 0.
function M.repeat_(t, length)
    return M.clamp(t - math.floor(t / length) * length, 0.0, length)
end

--- Calculates the shortest difference between two given angles (in degrees).
function M.delta_angle(a, b)
    local diff = M.repeat_((b - a), 360)
    if diff > 180 then
        diff = diff - 360
    end
    return diff
end

--- Clamps x between 0 and 1 and returns value.
function M.clamp01(x)
    if x < 0 then
        return 0
    elseif x > 1 then
        return 1
    else
        return x
    end
end

--- Linearly interpolate between two values.
-- Use the optional argument `dt` to perform an accurate framerate-independent linear interpolation with delta-time,
-- where `t` is the lerp coefficient per second. So t = 0.5 halves the difference every second.
-- Based on the @ross.grams code, https://forum.defold.com/t/lua-utility-functions/70526/14
-- @param t The interpolation value between the two floats. The value is clamped to the range [0, 1].
-- @param a The start value.
-- @param b The end value.
-- @param[opt] dt Delta-time.
-- @return An interpolated value.
function M.lerp(t, a, b, dt)
    t = M.clamp01(t)
    if dt then
        local diff = a - b
        return diff * (1 - t) ^ dt + b
    else
        return vmath.lerp(t, a, b)
    end
end

--- Same as `vmath.lerp` but `max_step` limits the increment of value.
-- @param t The interpolation value between the two floats. The value is clamped to the range [0, 1].
-- @param a The start value.
-- @param b The end value.
-- @param max_step The maximum increment of the value.
-- @return An interpolated value.
function M.limited_lerp(t, a, b, max_step)
    if scene3d.is_vector3(a) then
        return vmath.vector3(
            M.limited_lerp(t, a.x, b.x, max_step), 
            M.limited_lerp(t, a.y, b.y, max_step), 
            M.limited_lerp(t, a.z, b.z, max_step))
    elseif scene3d.is_vector4(a) then
        return vmath.vector4(
            M.limited_lerp(t, a.x, b.x, max_step), 
            M.limited_lerp(t, a.y, b.y, max_step), 
            M.limited_lerp(t, a.z, b.z, max_step), 
            M.limited_lerp(t, a.w, b.w, max_step))
    end

    local v = (b - a) * M.clamp01(t)
    if v < 0 then
        return a + math.max(v, -max_step)
    else
        return a + math.min(v, max_step)
    end
end

--- Same as `vmath.lerp` but makes sure the values interpolate correctly when they wrap around 360 degrees.
-- Use the optional argument `dt` to perform an accurate framerate-independent linear interpolation with delta-time,
-- where `t` is the lerp coefficient per second. So t = 0.5 halves the difference every second.
-- Based on the @ross.grams code, https://forum.defold.com/t/lua-utility-functions/70526/14
-- @param t The interpolation value between the two angles. The value is clamped to the range [0, 1].
-- @param a Degrees, the start value.
-- @param b Degrees, the end value.
-- @param[opt] dt Delta-time.
-- @return An interpolated value.
function M.lerp_angle(t, a, b, dt)
    t = M.clamp01(t)
    if dt then
        local diff = M.delta_angle(b, a)
        return diff * (1 - t) ^ dt + b
    else
        local diff = M.delta_angle(a, b)
        return a + diff * t
    end
end

--- Calculates the lerp parameter between of two values.
-- @param t Value between start and end.
-- @param a Start value.
-- @param b End value.
-- @return A percentage of value between start and end.
function M.inverse_lerp(t, a, b)
    if a ~= b then
        return M.clamp01((t - a) / (b - a))
    else
        return 0.0
    end
end

--- Moves the `a` value towards `b`.
-- @param a Current value.
-- @param b Target value.
-- @param max_delta A maximum change that should be applied to the value.
-- @return An interpolated value.
function M.move_towards(a, b, max_delta)
    if math.abs(b - a) <= max_delta then
        return b
    end
    return a + M.sign(b - a) * max_delta
end

--- Pingpongs the value t, so that it is never larger than length and never smaller than 0.
function M.ping_pong(t, length)
    t = M.repeat_(t, length * 2)
    return length - math.abs(t - length)
end

--- Interpolates between min and max with smoothing at the limits.
function M.smooth_step(x, min, max)
    if scene3d.is_vector3(x) then
        return vmath.vector3(M.smooth_step(x.x, min, max), M.smooth_step(x.y, min, max), M.smooth_step(x.z, min, max))
    end
    x = M.clamp(x, min, max)
    local v1 = (x - min) / (max - min)
    local v2 = (x - min) / (max - min)
    return -2 * v1 * v1 * v1 + 3 * v2 * v2
end

--- Gradually changes a value towards a desired goal over time.
-- Based on Game Programming Gems 4, pp. 98-101.
-- @param a Current value.
-- @param b Target value.
-- @param cur_velocity The current velocity.
-- @param smooth_time Approximately the time it will take to reach the target. A smaller value will result in a faster arrival at the target.
-- @param max_speed Optionally clamp the maximum speed.
-- @param dt Delta time.
-- @return An interpolated value.
-- @usage
-- local obj_position = go.get("/object_to_follow", "position")
-- local camera_pos = go.get("/camera_object", "position")
-- local cur_velocity = self.camera_velocity -- The type is `vmath.vector3(0)`. Store this variable somewhere, for example in `self`.
-- local smooth_time = 0.3
-- local max_speed = nil
-- -- dt is defined in `update()`
-- camera_pos.x, cur_velocity.x = math3d.smooth_damp(camera_pos.x, obj_position.x, cur_velocity.x, smooth_time, max_speed, dt)
-- camera_pos.y, cur_velocity.x = math3d.smooth_damp(camera_pos.x, obj_position.x, cur_velocity.x, smooth_time, max_speed, dt)
-- camera_pos.z, cur_velocity.z = math3d.smooth_damp(camera_pos.z, obj_position.z, cur_velocity.z, smooth_time, max_speed, dt)
-- go.set("/camera_object", "position", camera_pos)
function M.smooth_damp(a, b, cur_velocity, smooth_time, max_speed, dt)
    smooth_time = math.max(0.0001, smooth_time)
    local omega = 2 / smooth_time

    local x = omega * dt
    local exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
    local change = a - b
    local initial_b = b

    if max_speed then
        local max_change = max_speed * smooth_time
        change = M.clamp(change, -max_change, max_change)
    end
    b = a - change

    local temp = (cur_velocity + omega * change) * dt
    cur_velocity = (cur_velocity - omega * temp) * exp
    local result = b + (change + temp) * exp

    if (initial_b - a > 0) == (result > initial_b) then
        result = initial_b
        cur_velocity = (result - initial_b) / dt
    end

    return result, cur_velocity
end

--- Gradually changes an angle (in degrees) towards a desired goal angle over time.
function M.smooth_damp_angle(a, b, cur_velocity, smooth_time, max_speed, dt)
    b = a + M.delta_angle(a, b)
    return M.smooth_damp(a, b, cur_velocity, smooth_time, max_speed, dt)
end
return M
