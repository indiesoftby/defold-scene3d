local M = {}

local DISTANCE_LINEAR = hash("linear")
local DISTANCE_INVERSE = hash("inverse")
local DISTANCE_EXPONENTIAL = hash("exponential")

-- https://developer.mozilla.org/en-US/docs/Web/API/PannerNode/distanceModel
function M.falloff(position1, position2, ref_distance, max_distance, rolloff_factor, distance_model)
    local distance = vmath.length(position1 - position2)

    if distance < ref_distance then
        return 1
    elseif distance > max_distance then
        return 0
    end

    local result = 0
    if distance_model == DISTANCE_LINEAR then
        result = 1 - rolloff_factor * (distance - ref_distance) / (max_distance - ref_distance)
    elseif distance_model == DISTANCE_INVERSE then
        result = ref_distance / (ref_distance + rolloff_factor * (distance - ref_distance))
    elseif distance_model == DISTANCE_EXPONENTIAL then
        result = math.pow(distance / ref_distance, -rolloff_factor)
    end

    return math3d.clamp01(result)
end

return M