--[[ Copy-paste the properies:

go.property("frustum_cull_enabled", true)
go.property("frustum_mesh_url", msg.url("#mesh")) -- optional
go.property("frustum_mesh_max_dimension", 1)
go.property("frustum_mesh_use_world_position", false)

--]]

local M = {}

function M.init(self, mesh_url)
    self.frustum_mesh = {}
    local s = self.frustum_mesh
    s.id = scene3d.frustum_mesh_acquire()

    mesh_url = mesh_url or self.frustum_mesh_url
    if self.frustum_cull_enabled then
        assert(mesh_url, "Mesh 'url' is required")
    end
    s.mesh_url = mesh_url
    if type(s.mesh_url) == "table" then
        s.many = true
    end
end

function M.final(self)
    local s = self.frustum_mesh

    scene3d.frustum_mesh_release(s.id)
end

function M.update(self, custom_position)
    if not self.frustum_cull_enabled then
        return
    end

    local s = self.frustum_mesh

    local max_dim = self.frustum_mesh_max_dimension
    local use_world_pos = self.frustum_mesh_use_world_position
    local changed, message_id = scene3d.frustum_mesh_vis_changed(s.id, max_dim, use_world_pos, custom_position)
    if changed then
        if s.many then
            for _, url in ipairs(s.mesh_url) do
                msg.post(url, message_id)
            end
        else
            msg.post(s.mesh_url, message_id)
        end
        s.visibility = message_id
    end
end

return M