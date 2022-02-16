local flow = require("ludobits.m.flow")

local M = {}

function M.window_callback(self, event, data)
    if event == window.WINDOW_EVENT_FOCUS_LOST then
        if html5 and self.loaded_proxy then
            self.pause_proxy = true
        end
    elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
        if html5 and self.loaded_proxy then
            self.unpause_proxy = true
        end
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

return M