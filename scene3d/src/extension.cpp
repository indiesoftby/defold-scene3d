
#include <dmsdk/sdk.h>

#include <algorithm>
#include <vector>
#include <cmath>
#include <cstring>

#include "frustum_cull.h"
#include "noise.h"

static int IsVector3(lua_State* L)
{
    lua_pushboolean(L, dmScript::IsVector3(L, 1));
    return 1;
}

static int IsVector4(lua_State* L)
{
    lua_pushboolean(L, dmScript::IsVector4(L, 1));
    return 1;
}

static int IsQuat(lua_State* L)
{
    lua_pushboolean(L, dmScript::IsQuat(L, 1));
    return 1;
}

static int GetRotationTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Quat& rotation    = dmGameObject::GetRotation(instance);

    dmVMath::Quat* out = dmScript::CheckQuat(L, 2);
    *out               = rotation;

    return 0;
}

static int GetWorldRotationTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Quat& rotation    = dmGameObject::GetWorldRotation(instance);

    dmVMath::Quat* out = dmScript::CheckQuat(L, 2);
    *out               = rotation;

    return 0;
}

static int GetPositionTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Point3& position  = dmGameObject::GetPosition(instance);

    dmVMath::Vector3* out = dmScript::CheckVector3(L, 2);
    out->setX(position.getX());
    out->setY(position.getY());
    out->setZ(position.getZ());

    return 0;
}

static int GetWorldPositionTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Point3& position  = dmGameObject::GetWorldPosition(instance);

    dmVMath::Vector3* out = dmScript::CheckVector3(L, 2);
    out->setX(position.getX());
    out->setY(position.getY());
    out->setZ(position.getZ());

    return 0;
}

static int GetScaleTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Vector3& scale    = dmGameObject::GetScale(instance);

    dmVMath::Vector3* out = dmScript::CheckVector3(L, 2);
    out->setX(scale.getX());
    out->setY(scale.getY());
    out->setZ(scale.getZ());

    return 0;
}

static int GetWorldScaleTo(lua_State* L)
{
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L, 1);
    const dmVMath::Vector3& scale    = dmGameObject::GetWorldScale(instance);

    dmVMath::Vector3* out = dmScript::CheckVector3(L, 2);
    out->setX(scale.getX());
    out->setY(scale.getY());
    out->setZ(scale.getZ());

    return 0;
}

#define SMALL_DOUBLE 0.0000000001

static dmVMath::Vector3 Orthogonal(const dmVMath::Vector3& v)
{
    using namespace dmVMath;

    return v.getZ() < v.getX() ? Vector3(v.getY(), -v.getX(), 0) : Vector3(0, -v.getZ(), v.getY());
}

static dmVMath::Quat FromToRotation(const dmVMath::Vector3& fromVector, const dmVMath::Vector3& toVector)
{
    using namespace dmVMath;

    float d = dot(fromVector, toVector);
    float k = sqrtf(lengthSqr(fromVector) * lengthSqr(toVector));
    if (fabs(d / k + 1) < 0.00001)
    {
        Vector3 ortho = Orthogonal(fromVector);
        return Quat(normalize(ortho), 0);
    }
    Vector3 c = cross(fromVector, toVector);
    return normalize(Quat(c, d + k));
}

// Creates a rotation with the specified forward and upwards directions.
// Based on https://github.com/YclepticStudios/gmath/blob/151591f7d9d433b55dc6cdc907bd33aa4232f3a1/src/Quaternion.hpp
static dmVMath::Quat LookRotation(dmVMath::Vector3 forward, dmVMath::Vector3 upwards)
{
    using namespace dmVMath;

    // Normalize inputs
    forward = normalize(forward);
    upwards = normalize(upwards);
    // Don't allow zero vectors
    if (lengthSqr(forward) < SMALL_DOUBLE || lengthSqr(upwards) < SMALL_DOUBLE)
        return Quat::identity();
    // Handle alignment with up direction
    if (1 - fabs(dot(forward, upwards)) < SMALL_DOUBLE)
        return FromToRotation(Vector3::zAxis(), forward);
    // Get orthogonal vectors
    Vector3 right = normalize(cross(upwards, forward));
    upwards       = cross(forward, right);
    // Calculate rotation
    Quat quaternion;
    float radicand = right.getX() + upwards.getY() + forward.getZ();
    if (radicand > 0)
    {
        quaternion.setW(sqrtf(1.0 + radicand) * 0.5);
        float recip = 1.0 / (4.0 * quaternion.getW());
        quaternion.setX((upwards.getZ() - forward.getY()) * recip);
        quaternion.setY((forward.getX() - right.getZ()) * recip);
        quaternion.setZ((right.getY() - upwards.getX()) * recip);
    }
    else if (right.getX() >= upwards.getY() && right.getX() >= forward.getZ())
    {
        quaternion.setX(sqrtf(1.0 + right.getX() - upwards.getY() - forward.getZ()) * 0.5);
        float recip = 1.0 / (4.0 * quaternion.getX());
        quaternion.setW((upwards.getZ() - forward.getY()) * recip);
        quaternion.setZ((forward.getX() + right.getZ()) * recip);
        quaternion.setY((right.getY() + upwards.getX()) * recip);
    }
    else if (upwards.getY() > forward.getZ())
    {
        quaternion.setY(sqrtf(1.0 - right.getX() + upwards.getY() - forward.getZ()) * 0.5);
        float recip = 1.0 / (4.0 * quaternion.getY());
        quaternion.setZ((upwards.getZ() + forward.getY()) * recip);
        quaternion.setW((forward.getX() - right.getZ()) * recip);
        quaternion.setX((right.getY() + upwards.getX()) * recip);
    }
    else
    {
        quaternion.setZ(sqrtf(1.0 - right.getX() - upwards.getY() + forward.getZ()) * 0.5);
        float recip = 1.0 / (4.0 * quaternion.getZ());
        quaternion.setY((upwards.getZ() + forward.getY()) * recip);
        quaternion.setX((forward.getX() + right.getZ()) * recip);
        quaternion.setW((right.getY() - upwards.getX()) * recip);
    }
    return quaternion;
}

static int Quat_LookRotation(lua_State* L)
{
    using namespace dmVMath;

    Vector3* forward = dmScript::CheckVector3(L, 1);
    if (dmScript::IsVector3(L, 2))
    {
        Vector3* upwards = dmScript::CheckVector3(L, 2);
        dmScript::PushQuat(L, LookRotation(*forward, *upwards));
    }
    else
    {
        dmScript::PushQuat(L, LookRotation(*forward, Vector3::yAxis()));
    }

    return 1;
}

static const dmhash_t MSG_ENABLE  = dmHashString64("enable");
static const dmhash_t MSG_DISABLE = dmHashString64("disable");

struct Frustum_Mesh
{
    bool m_Active;
    bool m_Visible;
    // glm::vec3 m_FrustumBounds[2];
};

static Frustum g_Frustum;
// TODO: replace vectors with dmSDK's arrays.
static std::vector<Frustum_Mesh> g_FrustumMeshes;
static std::vector<std::vector<Frustum_Mesh>::size_type> g_FrustumMeshesFreeIds;

static int Frustum_Set(lua_State* L)
{
    dmVMath::Matrix4* m = dmScript::CheckMatrix4(L, 1);
    g_Frustum           = Frustum(*m);

    return 0;
}

static int Frustum_Is_Box_Visible(lua_State* L)
{
    dmVMath::Vector3 bounds[2];
    if (lua_isnumber(L, 1))
    {
        bounds[0].setX(luaL_checknumber(L, 1));
        bounds[0].setY(luaL_checknumber(L, 2));
        bounds[0].setZ(luaL_checknumber(L, 3));
        bounds[1].setX(luaL_checknumber(L, 4));
        bounds[1].setY(luaL_checknumber(L, 5));
        bounds[1].setZ(luaL_checknumber(L, 6));
    }
    else
    {
        dmVMath::Vector3* v1 = dmScript::CheckVector3(L, 1);
        bounds[0]            = dmVMath::Vector3(*v1);

        dmVMath::Vector3* v2 = dmScript::CheckVector3(L, 2);
        bounds[1]            = dmVMath::Vector3(*v2);
    }

    const bool visible = g_Frustum.IsBoxVisible(bounds[0], bounds[1]);

    lua_pushboolean(L, visible);
    return 1;
}

static int Frustum_Mesh_Acquire(lua_State* L)
{
    std::vector<Frustum_Mesh>::size_type idx;
    if (!g_FrustumMeshesFreeIds.empty())
    {
        idx = g_FrustumMeshesFreeIds.back();
        g_FrustumMeshesFreeIds.pop_back();
    }
    else
    {
        g_FrustumMeshes.push_back(Frustum_Mesh());
        idx = g_FrustumMeshes.size() - 1;
    }

    Frustum_Mesh& mesh = g_FrustumMeshes[idx];
    mesh.m_Active      = true;
    mesh.m_Visible     = true;

    lua_pushnumber(L, idx);
    return 1;
}

static int Frustum_Mesh_Release(lua_State* L)
{
    const int idx = luaL_checkint(L, 1);
    g_FrustumMeshesFreeIds.push_back(idx);
    g_FrustumMeshes[idx].m_Active  = false;
    g_FrustumMeshes[idx].m_Visible = false;

    return 0;
}

static int Frustum_Mesh_Visibility_Changed(lua_State* L)
{
    const int idx      = luaL_checkint(L, 1);
    Frustum_Mesh& mesh = g_FrustumMeshes[idx];

    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L);
    dmVMath::Vector3 scale           = dmGameObject::GetScale(instance);

    dmVMath::Point3 position;
    if (dmScript::IsVector3(L, 4))
    {
        dmVMath::Vector3* v = dmScript::CheckVector3(L, 4);
        position            = dmVMath::Point3(*v);
    }
    else
    {
        if (lua_toboolean(L, 3))
        {
            position = dmGameObject::GetWorldPosition(instance);
        }
        else
        {
            position = dmGameObject::GetPosition(instance);
        }
    }

    const float max_scale     = std::max(std::max(scale.getX(), scale.getY()), scale.getZ());
    const float max_dimension = luaL_checknumber(L, 2) * max_scale;

    dmVMath::Vector3 bounds[2];
    bounds[0] = dmVMath::Vector3(position.getX() - max_dimension, position.getY() - max_dimension, position.getZ() - max_dimension);
    bounds[1] = dmVMath::Vector3(position.getX() + max_dimension, position.getY() + max_dimension, position.getZ() + max_dimension);

    const bool visible = g_Frustum.IsBoxVisible(bounds[0], bounds[1]);

    if (visible != mesh.m_Visible)
    {
        mesh.m_Visible = visible;
        lua_pushboolean(L, true);
        dmScript::PushHash(L, visible ? MSG_ENABLE : MSG_DISABLE);
        return 2;
    }
    else
    {
        lua_pushboolean(L, false);
        return 1;
    }
}

static int Frustum_Mesh_Visibility_Changed_Box(lua_State* L)
{
    const int idx      = luaL_checkint(L, 1);
    Frustum_Mesh& mesh = g_FrustumMeshes[idx];

    dmVMath::Vector3 bounds[2];
    if (lua_isnumber(L, 2))
    {
        bounds[0].setX(luaL_checknumber(L, 2));
        bounds[0].setY(luaL_checknumber(L, 3));
        bounds[0].setZ(luaL_checknumber(L, 4));
        bounds[1].setX(luaL_checknumber(L, 5));
        bounds[1].setY(luaL_checknumber(L, 6));
        bounds[1].setZ(luaL_checknumber(L, 7));
    }
    else
    {
        dmVMath::Vector3* v1 = dmScript::CheckVector3(L, 2);
        bounds[0]            = dmVMath::Vector3(*v1);

        dmVMath::Vector3* v2 = dmScript::CheckVector3(L, 3);
        bounds[1]            = dmVMath::Vector3(*v2);
    }

    const bool visible = g_Frustum.IsBoxVisible(bounds[0], bounds[1]);

    if (visible != mesh.m_Visible)
    {
        mesh.m_Visible = visible;
        lua_pushboolean(L, true);
        dmScript::PushHash(L, visible ? MSG_ENABLE : MSG_DISABLE);
        return 2;
    }
    else
    {
        lua_pushboolean(L, false);
        return 1;
    }
}

static int ChunkIdHash(lua_State* L)
{
    const int x = luaL_checkint(L, 1);
    const int y = luaL_checkint(L, 2);

    const uint32_t x32 = (uint16_t)x;
    const uint32_t y32 = (uint16_t)y;
    const uint32_t id  = (x32 << 16) | y32;

    lua_pushinteger(L, id);
    return 1;
}

struct PreRenderCallback
{
    std::vector<PreRenderCallback>::size_type m_Id;
    dmScript::LuaCallbackInfo* m_Callback;
    int m_Priority;
};

static bool g_PreRenderCallbacksLock;
// TODO: replace vectors with dmSDK's arrays.
static std::vector<PreRenderCallback> g_PreRenderCallbacks;
static std::vector<PreRenderCallback>::size_type g_PreRenderCallbacksNextId = 1;

bool CompareByPriority(PreRenderCallback a, PreRenderCallback b)
{
    return a.m_Priority < b.m_Priority;
}

static int PreRender_AddCallback(lua_State* L)
{
    if (g_PreRenderCallbacksLock)
    {
        return luaL_error(L, "Can't add callback during its invocation.");
    }
    dmScript::LuaCallbackInfo* cb = dmScript::CreateCallback(L, 1);
    const int priority            = lua_isnumber(L, 2) ? luaL_checkint(L, 2) : 1;

    PreRenderCallback callback = PreRenderCallback();
    callback.m_Id              = g_PreRenderCallbacksNextId;
    callback.m_Callback        = cb;
    callback.m_Priority        = priority;

    g_PreRenderCallbacks.push_back(callback);
    g_PreRenderCallbacksNextId++;

    lua_pushnumber(L, callback.m_Id);
    return 1;
}

static int PreRender_RemoveCallback(lua_State* L)
{
    if (g_PreRenderCallbacksLock)
    {
        return luaL_error(L, "Can't remove callback during its invocation.");
    }

    const int callback_id = luaL_checkint(L, 1);

    std::vector<PreRenderCallback>::size_type size = g_PreRenderCallbacks.size();
    for (std::vector<PreRenderCallback>::size_type idx = 0; idx < size; ++idx)
    {
        PreRenderCallback& callback = g_PreRenderCallbacks[idx];
        if (callback.m_Id == callback_id)
        {
            if (dmScript::IsCallbackValid(callback.m_Callback))
            {
                dmScript::DestroyCallback(callback.m_Callback);
            }
            g_PreRenderCallbacks.erase(g_PreRenderCallbacks.begin() + idx);

            lua_pushboolean(L, true);
            return 1;
        }
    }

    lua_pushboolean(L, false);
    return 1;
}

static void PreRender_ClearCallbacks()
{
    std::vector<PreRenderCallback>::size_type size = g_PreRenderCallbacks.size();
    for (std::vector<PreRenderCallback>::size_type idx = 0; idx < size; ++idx)
    {
        PreRenderCallback& callback = g_PreRenderCallbacks[idx];
        if (dmScript::IsCallbackValid(callback.m_Callback))
        {
            dmScript::DestroyCallback(callback.m_Callback);
        }
    }

    g_PreRenderCallbacks.clear();
}

static void PreRender_InvokeCallbacks()
{
    g_PreRenderCallbacksLock = true;

    std::sort(g_PreRenderCallbacks.begin(), g_PreRenderCallbacks.end(), CompareByPriority);

    std::vector<PreRenderCallback>::size_type size = g_PreRenderCallbacks.size();
    for (std::vector<PreRenderCallback>::size_type idx = 0; idx < size;)
    {
        PreRenderCallback& callback = g_PreRenderCallbacks[idx];
        if (!dmScript::IsCallbackValid(callback.m_Callback))
        {
            g_PreRenderCallbacks.erase(g_PreRenderCallbacks.begin() + idx);
            continue;
        }

        lua_State* L = dmScript::GetCallbackLuaContext(callback.m_Callback);
        if (!dmScript::SetupCallback(callback.m_Callback))
        {
            dmScript::DestroyCallback(callback.m_Callback);
            g_PreRenderCallbacks.erase(g_PreRenderCallbacks.begin() + idx);
            continue;
        }

        dmScript::PCall(L, 1, 0);
        dmScript::TeardownCallback(callback.m_Callback);

        ++idx;
    }

    g_PreRenderCallbacksLock = false;
}

static int Simplex_Seed(lua_State* L)
{
    int seed = luaL_checkinteger(L, 1);
    Simplex::Seed(seed);

    return 0;
}

static int Simplex_Noise2(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);

    int octaves       = 1;
    float persistence = 0.5f;
    float lacunarity  = 2.0f;

    if (lua_isnumber(L, 3))
        octaves = lua_tointeger(L, 3);
    if (lua_isnumber(L, 4))
        persistence = lua_tonumber(L, 4);
    if (lua_isnumber(L, 5))
        lacunarity = lua_tonumber(L, 5);

    if (octaves <= 0)
    {
        return luaL_error(L, "Expected octaves value > 0");
    }

    const float result = Simplex::FractalNoise2(x, y, octaves, persistence, lacunarity);
    lua_pushnumber(L, result);

    return 1;
}

static int Simplex_Noise3(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    float z = luaL_checknumber(L, 3);

    int octaves       = 1;
    float persistence = 0.5f;
    float lacunarity  = 2.0f;

    if (lua_isnumber(L, 4))
        octaves = lua_tointeger(L, 4);
    if (lua_isnumber(L, 5))
        persistence = lua_tonumber(L, 5);
    if (lua_isnumber(L, 6))
        lacunarity = lua_tonumber(L, 6);

    if (octaves <= 0)
    {
        return luaL_error(L, "Expected octaves value > 0");
    }

    const float result = Simplex::FractalNoise3(x, y, z, octaves, persistence, lacunarity);
    lua_pushnumber(L, result);

    return 1;
}

static int Simplex_Noise4(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    float z = luaL_checknumber(L, 3);
    float w = luaL_checknumber(L, 4);

    int octaves       = 1;
    float persistence = 0.5f;
    float lacunarity  = 2.0f;

    if (lua_isnumber(L, 5))
        octaves = lua_tointeger(L, 5);
    if (lua_isnumber(L, 6))
        persistence = lua_tonumber(L, 6);
    if (lua_isnumber(L, 7))
        lacunarity = lua_tonumber(L, 7);

    if (octaves <= 0)
    {
        return luaL_error(L, "Expected octaves value > 0");
    }

    const float result = Simplex::FractalNoise4(x, y, z, w, octaves, persistence, lacunarity);
    lua_pushnumber(L, result);

    return 1;
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] = {
    { "is_vector3", IsVector3 },
    { "is_vector4", IsVector4 },
    { "is_quat", IsQuat },
    //
    { "get_position_to", GetPositionTo },
    { "get_world_position_to", GetWorldPositionTo },
    { "get_rotation_to", GetRotationTo },
    { "get_world_rotation_to", GetWorldRotationTo },
    { "get_scale_to", GetScaleTo },
    { "get_world_scale_to", GetWorldScaleTo },
    //
    { "quat_look_rotation", Quat_LookRotation },
    { "frustum_set", Frustum_Set },
    { "frustum_is_box_visible", Frustum_Is_Box_Visible },
    { "frustum_mesh_acquire", Frustum_Mesh_Acquire },
    { "frustum_mesh_release", Frustum_Mesh_Release },
    { "frustum_mesh_vis_changed", Frustum_Mesh_Visibility_Changed },
    { "frustum_mesh_vis_changed_box", Frustum_Mesh_Visibility_Changed_Box },
    //
    { "chunk_id_hash", ChunkIdHash },
    //
    { "prerender_register", PreRender_AddCallback },
    { "prerender_unregister", PreRender_RemoveCallback },
    //
    { "simplex_seed", Simplex_Seed },
    { "simplex_noise2", Simplex_Noise2 },
    { "simplex_noise3", Simplex_Noise3 },
    { "simplex_noise4", Simplex_Noise4 },
    /* Sentinel: */
    { NULL, NULL }
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);

    // Register lua names
    luaL_register(L, "scene3d", Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result InitializeExt(dmExtension::Params* params)
{
    LuaInit(params->m_L);

    g_FrustumMeshes.reserve(1000);

    return dmExtension::RESULT_OK;
}

static dmExtension::Result OnPreRender(dmExtension::Params* params)
{
    PreRender_InvokeCallbacks();

    return dmExtension::RESULT_OK;
}

static dmExtension::Result OnPostRender(dmExtension::Params* params)
{
    // Nothing here yet.
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppInitializeExt(dmExtension::AppParams* params)
{
    dmExtension::RegisterCallback(dmExtension::CALLBACK_PRE_RENDER, OnPreRender);
    dmExtension::RegisterCallback(dmExtension::CALLBACK_POST_RENDER, OnPostRender);

    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeExt(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeExt(dmExtension::AppParams* params)
{
    PreRender_ClearCallbacks();

    return dmExtension::RESULT_OK;
}

static dmExtension::Result OnUpdateExt(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

DM_DECLARE_EXTENSION(scene3d, "scene3d", AppInitializeExt, AppFinalizeExt, InitializeExt, OnUpdateExt, 0, FinalizeExt)
