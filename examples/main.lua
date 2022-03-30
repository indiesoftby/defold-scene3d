local flow = require("ludobits.m.flow")

local M = {}

-- Not used...
function M.window_callback(self, event, data)
    if event == window.WINDOW_EVENT_FOCUS_LOST then
    elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
    elseif event == window.WINDOW_EVENT_ICONFIED then
    elseif event == window.WINDOW_EVENT_DEICONIFIED then
    elseif event == window.WINDOW_EVENT_RESIZED then
    end
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