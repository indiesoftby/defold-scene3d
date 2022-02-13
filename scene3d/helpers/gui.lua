local M = {}

local COLOR_W = hash("color.w")
local SCALE = hash("scale")

function M.init_node(self, name, alpha)
    self[name] = gui.get_node(name)

    if alpha ~= nil then
        M.set_alpha(self[name], alpha)
    end
end

function M.get_alpha(node)
    return gui.get_alpha(node)
end

function M.set_alpha(node, alpha)
    gui.set_alpha(node, alpha)
    if alpha <= 0 then
        gui.set_enabled(node, false)
    else
        gui.set_enabled(node, true)
    end
end

local function anim_alpha_callback(self, node)
    if M.get_alpha(node) <= 0 then
        gui.set_enabled(node, false)
    else
        gui.set_enabled(node, true)
    end
end

function M.anim_alpha(node, alpha, duration, delay, callback)
    gui.set_enabled(node, true)
    duration = duration or 0.3
    delay = delay or 0
    gui.cancel_animation(node, COLOR_W)
    if callback then
        gui.animate(node, COLOR_W, alpha, gui.EASING_OUTQUAD, duration, delay, function(self)
            anim_alpha_callback(self, node)
            callback(self)
        end)
    else
        gui.animate(node, COLOR_W, alpha, gui.EASING_OUTQUAD, duration, delay, anim_alpha_callback)
    end
end

function M.set_scale(node, scale)
    if type(scale) == "number" then
        scale = vmath.vector3(scale)
    end
    gui.set_scale(node, scale)
end

function M.set_scale_x(node, x)
    local scale = gui.get_scale(node)
    scale.x = x
    gui.set_scale(node, scale)
end

function M.set_scale_y(node, y)
    local scale = gui.get_scale(node)
    scale.y = y
    gui.set_scale(node, scale)
end

function M.anim_scale(node, scale, easing, duration, delay)
    if type(scale) == "number" then
        scale = vmath.vector3(scale)
    end
    easing = easing or gui.EASING_OUTQUAD
    duration = duration or 0.0001
    delay = delay or 0
    gui.cancel_animation(node, SCALE)
    gui.animate(node, SCALE, scale, easing, duration, delay)
end

function M.get_x(node)
    return gui.get_position(node).x
end

function M.set_x(node, v)
    local p = gui.get_position(node)
    p.x = v
    gui.set_position(node, p)
end

function M.get_y(node)
    return gui.get_position(node).y
end

function M.set_y(node, v)
    local p = gui.get_position(node)
    p.y = v
    gui.set_position(node, p)
end

function M.get_z(node)
    return gui.get_position(node).z
end

function M.set_z(node, v)
    local p = gui.get_position(node)
    p.z = v
    gui.set_position(node, p)
end

function M.get_text_size(node, text)
    local font = gui.get_font_resource(gui.get_font(node))
    local metrics = resource.get_text_metrics(font, text, {})
    return metrics
end

return M