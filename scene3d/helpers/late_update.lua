local render3d = require("scene3d.render.render3d")

local M = {}

M.LATE_UPDATE = hash("late_update")
-- M.RESPONSE_OK = hash("response_ok")

local SUBSCRIBE = hash("subscribe")
local UNSUBSCRIBE = hash("unsubscribe")
local LATE_UPDATE_SCRIPT = "/late_update#late_update"

local subscriber_id = 0

local function sort_by_priority(a, b)
    if a.priority == b.priority then
        return a.id < b.id
    else
        return a.priority < b.priority
    end
end

local function update_call_list(self)
    self.call_list = {}
    for _, s in pairs(self.subscribers) do
        table.insert(self.call_list, s)
    end
    table.sort(self.call_list, sort_by_priority)

    -- print("call list:")
    -- for _, s in ipairs(self.call_list) do
    --     print(s.priority, s.id)
    -- end
end

function M._init(self)
    -- self.queue = {}
    self.subscribers = {}
    self.call_list = {}
end

function M._late_update_all(self)
    print(render3d.frame_num .. " - late_update: update all")

    for _, s in ipairs(self.call_list) do
        -- print(s.priority, s.id)
        msg.post(s.receiver, M.LATE_UPDATE)
    end
end

function M._subscribe(self, receiver, id, priority)
    if not receiver then
        subscriber_id = subscriber_id + 1
        msg.post(LATE_UPDATE_SCRIPT, SUBSCRIBE, { id = subscriber_id, priority = priority })
        -- print("subscribe msg", subscriber_id)
        return subscriber_id
    end

    if not self.subscribers then
        M._init(self)
    end

    local s = {
        receiver = receiver,
        priority = priority or 1
    }

    if not id then
        subscriber_id = subscriber_id + 1
        id = subscriber_id
    end
    -- print("add as id", id, receiver)

    s.id = id
    self.subscribers[id] = s

    update_call_list(self)

    return id
end

function M._unsubscribe(self, id)
    local s = self.subscribers[id]
    assert(s, "Subscriber " .. tostring(id) .. " is not found")

    self.subscribers[id] = nil
    update_call_list(self)
end

--
-- Public API
--

---
-- @param priority The higher the value, the later the subscriber is called.
-- @return The subscriber ID
function M.subscribe(priority)
    return M._subscribe(nil, nil, nil, priority)
end

---
-- @param id The subscriber ID
function M.unsubscribe(id)
    msg.post(LATE_UPDATE_SCRIPT, UNSUBSCRIBE, { id = id })
end

-- function M.queue(receiver)
-- end

return M