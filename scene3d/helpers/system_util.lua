local M = {}

local IS_DEBUG = sys.get_engine_info().is_debug
local SYSTEM_NAME = sys.get_sys_info().system_name
local ENGINE_VERSION = {}
for num in sys.get_engine_info().version:gmatch("%d+") do 
    table.insert(ENGINE_VERSION, tonumber(num))
end

--- Returns true if `major.minor.patch` >= the engine version
function M.engine_version(major, minor, patch)
    return ENGINE_VERSION[1] > major or 
    (ENGINE_VERSION[1] == major and ENGINE_VERSION[2] > minor) or 
    (ENGINE_VERSION[1] == major and ENGINE_VERSION[2] == minor and ENGINE_VERSION[3] >= patch)
end

--- Resizes game window to fit screen size. Use it to simplify your development process.
function M.resize_window()
    if SYSTEM_NAME ~= "Windows" and SYSTEM_NAME ~= "Darwin" and SYSTEM_NAME ~= "Linux" then
        return
    end
    assert(defos, "`defos` is required: https://github.com/subsoap/defos")

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

--- Setups Lua error handler if the non-debug build of the game runs in a browser.
-- It helps a lot to track stupid release-only errors.
function M.setup_error_handling()
    if not html5 then
        return
    end

    if IS_DEBUG then
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

return M