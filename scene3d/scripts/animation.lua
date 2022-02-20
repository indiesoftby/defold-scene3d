-- Check the animation.script file for the required gameobject properties.

local M = {
    ANIMATION_PLAY = hash("animation_play"),
    ANIMATION_CANCEL = hash("animation_cancel"),

    EASING_LINEAR = hash("linear"),
    EASING_INQUAD = hash("inquad"),
    EASING_OUTQUAD = hash("outquad"),
    EASING_INOUTQUAD = hash("inoutquad"),
    EASING_OUTINQUAD = hash("outinquad"),
    EASING_INCUBIC = hash("incubic"),
    EASING_OUTCUBIC = hash("outcubic"),
    EASING_INOUTCUBIC = hash("inoutcubic"),
    EASING_OUTINCUBIC = hash("outincubic"),
    EASING_INQUART = hash("inquart"),
    EASING_OUTQUART = hash("outquart"),
    EASING_INOUTQUART = hash("inoutquart"),
    EASING_OUTINQUART = hash("outinquart"),
    EASING_INQUINT = hash("inquint"),
    EASING_OUTQUINT = hash("outquint"),
    EASING_INOUTQUINT = hash("inoutquint"),
    EASING_OUTINQUINT = hash("outinquint"),
    EASING_INSINE = hash("insine"),
    EASING_OUTSINE = hash("outsine"),
    EASING_INOUTSINE = hash("inoutsine"),
    EASING_OUTINSINE = hash("outinsine"),
    EASING_INEXPO = hash("inexpo"),
    EASING_OUTEXPO = hash("outexpo"),
    EASING_INOUTEXPO = hash("inoutexpo"),
    EASING_OUTINEXPO = hash("outinexpo"),
    EASING_INCIRC = hash("incirc"),
    EASING_OUTCIRC = hash("outcirc"),
    EASING_INOUTCIRC = hash("inoutcirc"),
    EASING_OUTINCIRC = hash("outincirc"),
    EASING_INELASTIC = hash("inelastic"),
    EASING_OUTELASTIC = hash("outelastic"),
    EASING_INOUTELASTIC = hash("inoutelastic"),
    EASING_OUTINELASTIC = hash("outinelastic"),
    EASING_INBACK = hash("inback"),
    EASING_OUTBACK = hash("outback"),
    EASING_INOUTBACK = hash("inoutback"),
    EASING_OUTINBACK = hash("outinback"),
    EASING_INBOUNCE = hash("inbounce"),
    EASING_OUTBOUNCE = hash("outbounce"),
    EASING_INOUTBOUNCE = hash("inoutbounce"),
    EASING_OUTINBOUNCE = hash("outinbounce"),
}

local easings = {
    [M.EASING_LINEAR] = go.EASING_LINEAR,
    [M.EASING_INQUAD] = go.EASING_INQUAD,
    [M.EASING_OUTQUAD] = go.EASING_OUTQUAD,
    [M.EASING_INOUTQUAD] = go.EASING_INOUTQUAD,
    [M.EASING_OUTINQUAD] = go.EASING_OUTINQUAD,
    [M.EASING_INCUBIC] = go.EASING_INCUBIC,
    [M.EASING_OUTCUBIC] = go.EASING_OUTCUBIC,
    [M.EASING_INOUTCUBIC] = go.EASING_INOUTCUBIC,
    [M.EASING_OUTINCUBIC] = go.EASING_OUTINCUBIC,
    [M.EASING_INQUART] = go.EASING_INQUART,
    [M.EASING_OUTQUART] = go.EASING_OUTQUART,
    [M.EASING_INOUTQUART] = go.EASING_INOUTQUART,
    [M.EASING_OUTINQUART] = go.EASING_OUTINQUART,
    [M.EASING_INQUINT] = go.EASING_INQUINT,
    [M.EASING_OUTQUINT] = go.EASING_OUTQUINT,
    [M.EASING_INOUTQUINT] = go.EASING_INOUTQUINT,
    [M.EASING_OUTINQUINT] = go.EASING_OUTINQUINT,
    [M.EASING_INSINE] = go.EASING_INSINE,
    [M.EASING_OUTSINE] = go.EASING_OUTSINE,
    [M.EASING_INOUTSINE] = go.EASING_INOUTSINE,
    [M.EASING_OUTINSINE] = go.EASING_OUTINSINE,
    [M.EASING_INEXPO] = go.EASING_INEXPO,
    [M.EASING_OUTEXPO] = go.EASING_OUTEXPO,
    [M.EASING_INOUTEXPO] = go.EASING_INOUTEXPO,
    [M.EASING_OUTINEXPO] = go.EASING_OUTINEXPO,
    [M.EASING_INCIRC] = go.EASING_INCIRC,
    [M.EASING_OUTCIRC] = go.EASING_OUTCIRC,
    [M.EASING_INOUTCIRC] = go.EASING_INOUTCIRC,
    [M.EASING_OUTINCIRC] = go.EASING_OUTINCIRC,
    [M.EASING_INELASTIC] = go.EASING_INELASTIC,
    [M.EASING_OUTELASTIC] = go.EASING_OUTELASTIC,
    [M.EASING_INOUTELASTIC] = go.EASING_INOUTELASTIC,
    [M.EASING_OUTINELASTIC] = go.EASING_OUTINELASTIC,
    [M.EASING_INBACK] = go.EASING_INBACK,
    [M.EASING_OUTBACK] = go.EASING_OUTBACK,
    [M.EASING_INOUTBACK] = go.EASING_INOUTBACK,
    [M.EASING_OUTINBACK] = go.EASING_OUTINBACK,
    [M.EASING_INBOUNCE] = go.EASING_INBOUNCE,
    [M.EASING_OUTBOUNCE] = go.EASING_OUTBOUNCE,
    [M.EASING_INOUTBOUNCE] = go.EASING_INOUTBOUNCE,
    [M.EASING_OUTINBOUNCE] = go.EASING_OUTINBOUNCE,
}

local EMPTY_HASH = hash("")

local function cancel(self)
    local s = self.animation
    if s.property then
        go.cancel_animations(s.url, s.property)
        s.property = nil
    end
end

local function play(self)
    local s = self.animation

    if self.animation_property ~= s.property then
        cancel(self)

        if self.animation_property ~= EMPTY_HASH then
            local easing = easings[self.animation_easing]
            assert(easing, "Invalid value of easing")

            local playback = self.animation_loop and go.PLAYBACK_LOOP_FORWARD or go.PLAYBACK_ONCE_FORWARD
            if self.animation_pingpong then
                playback = self.animation_loop and go.PLAYBACK_LOOP_PINGPONG or go.PLAYBACK_ONCE_PINGPONG
            end
            go.animate(s.url, self.animation_property, playback, self.animation_to, easing, self.animation_duration)
            s.property = self.animation_property
        end
    end
end

function M.init(self)
    self.animation = {}
    local s = self.animation

    s.url = "."

    if self.animation_autoplay then
        play(self)
    end
end

function M.final(self)
end

function M.update(self, dt)
end

function M.on_message(self, message_id, message, sender)
    if message_id == M.ANIMATION_PLAY then
        play(self)
    elseif message_id == M.ANIMATION_CANCEL then
        cancel(self)
    end
end

return M