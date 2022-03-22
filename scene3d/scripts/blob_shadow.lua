-- Check the blob_shadow.script file for the required gameobject properties.

local render3d = require("scene3d.render.render3d")
local math3d = require("scene3d.helpers.math3d")

local M = {
    BLOB_SHADOW_UPDATE = hash("blob_shadow_update"),
    BLOB_SHADOW_DELETE = hash("blob_shadow_delete")
}

local CLOSEST = { all = false }

local EMPTY_HASH = hash("")
local SPRITE = hash("sprite")
local SIZE = hash("size")
local TINT = hash("tint")
local EULER_Y = hash("euler.y")

local DISABLE = hash("disable")
local ENABLE = hash("enable")

local V3_ONE = vmath.vector3(1)
local V3_ZERO = vmath.vector3(0)
local Q_IDENT = vmath.quat()

-- Original code used `xmath.*` functions to reduce GC pressure. 
-- So, `TMP_*` is kept here for possible future changes.
local TMP_ROT = vmath.quat()
local TMP_POS = vmath.vector3()
local TMP_SCALE = vmath.vector3()
local TMP_TINT = vmath.vector4()

local function update_base_scale(self)
    local s = self.blob_shadow

    local sprite_size = go.get(s.blob_sprite_url, SIZE)
    s.base_scale = s.scale * (1 / math.max(sprite_size.x, sprite_size.y))
end

local function init_options(self)
    local s = self.blob_shadow

    s.tint = self.blob_shadow_tint
    s.blend_mode = self.blob_shadow_blend_mode
    s.scale = self.blob_shadow_scale
    s.apply_object_scale = self.blob_shadow_apply_object_scale
    s.apply_object_euler_y = self.blob_shadow_apply_object_euler_y
    s.use_light_direction = self.blob_shadow_use_light_direction
    s.direction = self.blob_shadow_direction
    s.offset = self.blob_shadow_offset
    s.max_distance = self.blob_shadow_max_distance
    s.distance_scale = self.blob_shadow_distance_scale
    s.distance_alpha = self.blob_shadow_distance_alpha
    s.raycast_groups = {}
    if self.blob_shadow_raycast_group1 ~= EMPTY_HASH then
        table.insert(s.raycast_groups, self.blob_shadow_raycast_group1)
    end
    if self.blob_shadow_raycast_group2 ~= EMPTY_HASH then
        table.insert(s.raycast_groups, self.blob_shadow_raycast_group2)
    end
    if self.blob_shadow_raycast_group3 ~= EMPTY_HASH then
        table.insert(s.raycast_groups, self.blob_shadow_raycast_group3)
    end
end

local function apply_options(self)
    
end

local function update_shadow(self)
    local s = self.blob_shadow

    scene3d.get_position_to(s.object_url, TMP_POS)
    if s.apply_object_scale then
        scene3d.get_scale_to(s.object_url, TMP_SCALE)
    else
        TMP_SCALE.x = 1
        TMP_SCALE.y = 1
        TMP_SCALE.z = 1
    end

    local FROM_POS = TMP_POS + s.offset
    local direction = s.use_light_direction and render3d.light_directional_direction or s.direction
    local TO_POS = FROM_POS + direction * s.max_distance
    local results = #s.raycast_groups and physics.raycast(FROM_POS, TO_POS, s.raycast_groups, CLOSEST) or nil
    if results then
        for _,result in ipairs(results) do
            local view_distance = vmath.length(render3d.view_position - result.position)
            local offset_depth = math.log10(math3d.clamp(view_distance, render3d.near, render3d.far) / (render3d.far - render3d.near) * 500 + 1) * 0.005

            -- DEBUG
            -- render3d.debug_log("VD " .. string.format("%.02f", view_distance) .. string.format(" (%.06f)", offset_depth))

            local dist = vmath.length(FROM_POS - result.position)
            local t = dist / s.max_distance

            if s.apply_object_euler_y then
                local euler_y = go.get(s.object_url, EULER_Y)
                TMP_ROT = math3d.quat_look_rotation(result.normal, render3d.FORWARD) * vmath.quat_rotation_z(math.rad(euler_y))
                go.set_rotation(TMP_ROT, s.blob_obj_url)
            end

            TMP_POS = result.position + result.normal * offset_depth
            go.set_position(TMP_POS, s.blob_obj_url)

            local dist_scale = vmath.lerp(t, 1, s.distance_scale)
            TMP_SCALE = vmath.mul_per_elem(TMP_SCALE, s.base_scale) * dist_scale
            go.set_scale(TMP_SCALE, s.blob_obj_url)

            local dist_alpha = vmath.lerp(t, 1, s.distance_alpha)
            TMP_TINT.x = s.tint.x
            TMP_TINT.y = s.tint.y
            TMP_TINT.z = s.tint.z
            TMP_TINT.w = s.tint.w * dist_alpha
            go.set(s.blob_sprite_url, TINT, TMP_TINT)

            if not s.enabled then
                msg.post(s.blob_obj_url, ENABLE)
                s.enabled = true
            end
        end
    else
        if s.enabled then
            msg.post(s.blob_obj_url, DISABLE)
            s.enabled = false
        end
    end
end

local function late_update(self)
    update_shadow(self)
end

--
-- Public
--

function M.init(self, options)
    local factory_url = self.blob_shadow_factory_url
    if factory_url == nil or factory_url == msg.url() then
        return
    end

    self.blob_shadow = options or {}
    local s = self.blob_shadow
    s.factory_url = factory_url

    init_options(self)

    local result, id = pcall(factory.create, s.factory_url, V3_ZERO, Q_IDENT, nil, V3_ONE)
    if not result then
        local err = id
        print("⚠⚠⚠ The factory " .. tostring(s.factory_url) .. " isn't found. Do not forget to add `blob_shadows.go` to your scene if you use the included blob shadows.")
        print(err)
        self.blob_shadow = nil
        return
    end
    s.object_url = msg.url(nil, go.get_id(), nil)
    s.blob_obj_url = msg.url(nil, id, nil)
    s.blob_sprite_url = msg.url(nil, id, SPRITE)
    s.enabled = true

    update_base_scale(self)

    if self.blob_shadow_late_update then
        s.late_update_id = scene3d.prerender_register(late_update)
    end
end

function M.final(self)
    local s = self.blob_shadow
    if not s then
        return
    end

    go.delete(s.blob_obj_url)

    if s.late_update_id then
        scene3d.prerender_unregister(s.late_update_id)
    end

    self.blob_shadow = nil
end

function M.update(self, dt)
    local s = self.blob_shadow
    if not s then
        return
    end

    if not s.late_update_id then
        update_shadow(self)
    end
end

function M.on_message(self, message_id, message, sender)
    local s = self.blob_shadow
    if not s then
        return
    end

    if message_id == M.BLOB_SHADOW_UPDATE then
        init_options(self)
        update_base_scale(self)
    elseif message_id == M.BLOB_SHADOW_DELETE then
        M.final(self)
    end
end

return M