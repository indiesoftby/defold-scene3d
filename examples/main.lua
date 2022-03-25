local flow = require("ludobits.m.flow")

local M = {}

function M.window_callback(self, event, data)
    if event == window.WINDOW_EVENT_FOCUS_LOST then
    elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
    elseif event == window.WINDOW_EVENT_ICONFIED then
    elseif event == window.WINDOW_EVENT_DEICONIFIED then
    elseif event == window.WINDOW_EVENT_RESIZED then
    end
end

function M.setup_error_handling()
    if not html5 then
        return
    end

    if sys.get_engine_info().is_debug then
        return
    end

    sys.set_error_handler(function(source, message, traceback)
        local s = source:gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "\\r")
        local m = message:gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "\\r")
        local t = traceback:gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "\\r")

        local pstatus, perr = pcall(html5.run, "console.warn('ERROR: (" .. s .. ")\\n" .. m .. "\\n" .. t .. "')")
        if not pstatus then
            print("FATAL: html5.run(..) failed: " .. perr)
        end
    end)
end

function M.load_scene(self, id)
    assert(self.loading_flag ~= true)
    self.loading_flag = true
    msg.post("#main_loading", "started")

    flow(function()
        if self.loaded_proxy then
            msg.post(self.loaded_proxy, hash("release_input_focus"))
            flow.unload(self.loaded_proxy)
        end

        local proxy_url = self.loaded_proxy
        if id then
            self.loaded_scene = id
            proxy_url = msg.url(nil, "/scenes", id)
        end
        flow.load_async(proxy_url)
        self.loaded_proxy = proxy_url
        msg.post(proxy_url, hash("acquire_input_focus"))

        self.loading_flag = nil
        msg.post("#main_loading", "completed")
    end, nil, error)
end

local SYSTEM_NAME = sys.get_sys_info().system_name

function M.resize_window()
    if SYSTEM_NAME ~= "Windows" and SYSTEM_NAME ~= "Darwin" and SYSTEM_NAME ~= "Linux" then
        return
    end
    assert(defos, "`defos` is required")

    local displays = defos.get_displays()
    local current_display_id = defos.get_current_display_id()
    local screen_width = displays[current_display_id].bounds.width
    local screen_height = displays[current_display_id].bounds.height

    local project_width = tonumber(sys.get_config("display.width", 1920))
    local project_height = tonumber(sys.get_config("display.height", 1080))

    -- Resize the window. The code doesn't respect HiDPi screens.
    local x, y, w, h = defos.get_view_size()
    w = project_width
    h = project_height
    while screen_height * 0.95 <= h or screen_width * 0.95 <= w do
        w = w * 0.75
        h = h * 0.75
    end
    defos.set_view_size(x, y, w, h)

    -- Center the window
    local x, y, w, h = defos.get_window_size()
    x = math.floor((screen_width - w) / 2)
    y = math.floor((screen_height - h) / 2)
    defos.set_window_size(x, y, w, h)
end

return M