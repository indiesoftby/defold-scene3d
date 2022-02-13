--[[ Copy-paste the properties:

go.property("collision_type", hash("dynamic"))
go.property("collision_group", hash(""))
go.property("collision_mask", hash(""))

--]]

local M = {
    COLLISION_UPDATE = hash("collision_update")
}

local DYNAMIC = hash("dynamic")
local STATIC = hash("static")
local TRIGGER = hash("trigger")

local ENABLE = hash("enable")
local DISABLE = hash("disable")

local EMPTY_HASH = hash("")

local function collision_update(self)
    local s = self.collision
    local collision_url

    -- TODO: 
    -- Rework as for-loop

    if s.static then
        if self.collision_type ~= STATIC then
            msg.post(msg.url(nil, nil, s.static), DISABLE)
        else
            collision_url = msg.url(nil, nil, s.static)
        end
    end

    if s.dynamic then
        if self.collision_type ~= DYNAMIC then
            msg.post(msg.url(nil, nil, s.dynamic), DISABLE)
        else
            collision_url = msg.url(nil, nil, s.dynamic)
        end
    end

    if s.trigger then
        if self.collision_type ~= TRIGGER then
            msg.post(msg.url(nil, nil, s.trigger), DISABLE)
        else
            collision_url = msg.url(nil, nil, s.trigger)
        end
    end

    if collision_url then
        if self.collision_group ~= EMPTY_HASH then
            physics.set_group(collision_url, self.collision_group)
        end
        if self.collision_mask ~= EMPTY_HASH then
            if s.collision_mask and s.collision_mask ~= self.collision_mask then
                physics.set_maskbit(collision_url, s.collision_mask, false)
            end
            physics.set_maskbit(collision_url, self.collision_mask, true)
            s.collision_mask = self.collision_mask
        end
    end
end

function M.init(self, options)
    self.collision = options or {}

    collision_update(self)
end

function M.final(self)
end

function M.update(self, dt)
end

function M.on_message(self, message_id, message, sender)
    if message_id == M.COLLISION_UPDATE then
        collision_update(self)
    end
end

return M