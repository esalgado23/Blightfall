local BFH = _G.Blightfall
if not BFH then return end
local ns = BFH.ns

local FPS = 30
local CELL = 128
local LOADING_FADE = 1.0
local PUTREFY_FADE = 0.15
local PREVIEW_IDLE_TIME = 2.0
local PUTREFY_TIME = 5.0 -- time at full opacity before Putrefy leaves on its own
local SOUL_TIMEOUT = 15.0 -- Soul Reaper leaves this long after Dark Transformation
local SOUL_FADE_OUT = 0.5

local PREFIX = {SOUL = "reaper", BLIGHT = "blight"}

-- The finale sheet was drawn on a 188px canvas, so it is shown that much
-- larger than the 128px spell animations to keep the artist's proportions.
local CELEBRATION_FPS = 60
local CELEBRATION_RATIO = 188 / 128

local display, main, outro, celebration, textFrame, counter, label, perfect, dragOverlay

local function Clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

---------------------------------------------------------------------------
-- Flipbook layer: plays one animation from AnimData pages on a texture.
---------------------------------------------------------------------------

local Layer = {}
Layer.__index = Layer

local function NewLayer(parent, levelOffset, freeSize)
    local l = setmetatable({}, Layer)
    l.frame = CreateFrame("Frame", nil, parent)
    if not freeSize then l.frame:SetAllPoints(parent) end
    l.frame:SetFrameLevel(parent:GetFrameLevel() + levelOffset)
    l.frame:Hide()

    l.tex = l.frame:CreateTexture(nil, "ARTWORK")
    l.tex:SetAllPoints()

    -- Additive copy of the current frame, used for the optional flash.
    l.glow = l.frame:CreateTexture(nil, "OVERLAY")
    l.glow:SetAllPoints()
    l.glow:SetBlendMode("ADD")
    l.glow:Hide()
    return l
end

function Layer:SetFrame(i)
    if i == self.lastFrame then return end
    self.lastFrame = i

    local data = self.data
    local page = data.pages[math.floor(i / data.perPage) + 1]
    local idx = i % data.perPage
    local side = page[2]

    if self.lastPath ~= page[1] then
        -- NEAREST keeps the pixel art crisp at any scale.
        self.tex:SetTexture(page[1], "CLAMP", "CLAMP", "NEAREST")
        self.glow:SetTexture(page[1], "CLAMP", "CLAMP", "NEAREST")
        self.lastPath = page[1]
    end

    local u = 1 / side
    local col, row = idx % side, math.floor(idx / side)
    self.tex:SetTexCoord(col * u, (col + 1) * u, row * u, (row + 1) * u)
    self.glow:SetTexCoord(col * u, (col + 1) * u, row * u, (row + 1) * u)
end

-- opts: duration (whole animation) or fps, loop, fadeIn, delay, onDone
function Layer:Play(key, opts)
    local data = ns.AnimData and ns.AnimData[key]
    if not data then
        self:Stop()
        return
    end
    opts = opts or {}
    self.key = key
    self.data = data
    self.t = -(opts.delay or 0)
    self.frameTime = opts.duration and (opts.duration / data.frames) or (1 / (opts.fps or FPS))
    self.loop = opts.loop
    self.fadeIn = opts.fadeIn or 0
    self.onDone = opts.onDone
    self.fadeOutStart = nil
    self.lastFrame = nil
    self.playing = true
    self.glow:Hide()
    self:SetFrame(0)
    self.frame:SetAlpha(self.t < 0 and 0 or (self.fadeIn > 0 and 0 or 1))
    self.frame:Show()
end

function Layer:Stop()
    self.playing = false
    self.onDone = nil
    self.key = nil
    self.frame:Hide()
end

function Layer:IsPending()
    return self.playing and self.t < 0
end

-- Seconds left before a delayed animation actually starts.
function Layer:PendingTime()
    if self.playing and self.t < 0 then return -self.t end
    return 0
end

function Layer:Update(elapsed)
    if not self.playing then return end
    self.t = self.t + elapsed
    if self.t < 0 then
        self.frame:SetAlpha(0)
        return
    end

    local frames = self.data.frames
    local idx = math.floor(self.t / self.frameTime)
    if idx >= frames then
        if self.loop then
            idx = idx % frames
        else
            self:SetFrame(frames - 1)
            self.playing = false
            local done = self.onDone
            self.onDone = nil
            if done then done() end
            return
        end
    end
    self:SetFrame(idx)
    local alpha = self.fadeIn > 0 and math.min(1, self.t / self.fadeIn) or 1
    if self.fadeOutStart then
        local left = 1 - (GetTime() - self.fadeOutStart) / self.fadeOutDuration
        if left <= 0 then
            local done = self.fadeOutDone
            self.fadeOutDone = nil
            self:Stop()
            if done then done() end
            return
        end
        alpha = alpha * left
    end
    self.frame:SetAlpha(alpha)
end

-- Fade from the current opacity to 0, then stop and call onDone.
function Layer:FadeOut(duration, onDone)
    if self.fadeOutStart or not self.playing then return end
    self.fadeOutStart = GetTime()
    self.fadeOutDuration = duration
    self.fadeOutDone = onDone
end

---------------------------------------------------------------------------
-- Display frame
---------------------------------------------------------------------------

local function ApplyFontString(fs, cfg)
    local flags = cfg.outline or ""
    if not fs:SetFont(cfg.font or "Fonts\\FRIZQT__.TTF", Clamp(cfg.size, 6, 64), flags) then
        fs:SetFont("Fonts\\FRIZQT__.TTF", Clamp(cfg.size, 6, 64), flags)
    end
    local c = cfg.color or {1, 1, 1, 1}
    fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
    local s = cfg.shadowColor or {0, 0, 0, 1}
    fs:SetShadowColor(s[1], s[2], s[3], s[4] or 1)
    if cfg.shadow then
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowOffset(0, 0)
    end
end

function BFH:InitializeDisplay()
    display = CreateFrame("Frame", "BlightfallDisplay", UIParent)
    display:SetFrameStrata("HIGH")
    display:SetClampedToScreen(true)
    display:SetMovable(true)
    self.display = display

    main = NewLayer(display, 2)
    outro = NewLayer(display, 4)
    celebration = NewLayer(display, 6, true)
    celebration.frame:SetPoint("CENTER", display, "CENTER")

    textFrame = CreateFrame("Frame", nil, display)
    textFrame:SetAllPoints(display)
    textFrame:SetFrameLevel(display:GetFrameLevel() + 10)

    counter = textFrame:CreateFontString(nil, "OVERLAY")
    counter:SetJustifyH("CENTER")
    label = textFrame:CreateFontString(nil, "OVERLAY")
    label:SetJustifyH("CENTER")
    perfect = textFrame:CreateFontString(nil, "OVERLAY")
    perfect:SetJustifyH("CENTER")
    perfect:SetText("PERFECT COMBO")
    perfect:Hide()

    dragOverlay = CreateFrame("Frame", nil, display, "BackdropTemplate")
    dragOverlay:SetAllPoints(display)
    dragOverlay:SetFrameLevel(display:GetFrameLevel() + 20)
    dragOverlay:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    dragOverlay:SetBackdropColor(0.62, 0.11, 1, 0.15)
    dragOverlay:SetBackdropBorderColor(0.62, 0.11, 1, 1)
    dragOverlay:EnableMouse(true)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:Hide()
    dragOverlay:SetScript("OnDragStart", function() display:StartMoving() end)
    dragOverlay:SetScript("OnDragStop", function()
        display:StopMovingOrSizing()
        local p, _, rp, x, y = display:GetPoint(1)
        BFH.db.point, BFH.db.relativePoint, BFH.db.x, BFH.db.y = p, rp, x, y
    end)

    display:SetScript("OnUpdate", function(_, elapsed) BFH:OnDisplayUpdate(elapsed) end)
    self:ApplyDisplaySettings()
    self:PreloadTextures()
end

-- Touch every page once at login so the first cast in combat doesn't hitch
-- while the client reads the textures from disk.
function BFH:PreloadTextures()
    if not ns.AnimData then return end
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetSize(1, 1)
    holder:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10, 10)
    holder:SetAlpha(0)
    local size = self.db.putrefySmall and "_sml_" or "_big_"
    for key, data in pairs(ns.AnimData) do
        if not key:find("^putrefy") or key:find(size, 1, true) then
            for _, page in ipairs(data.pages) do
                local t = holder:CreateTexture(nil, "BACKGROUND")
                t:SetSize(1, 1)
                t:SetPoint("CENTER")
                t:SetTexture(page[1], "CLAMP", "CLAMP", "NEAREST")
            end
        end
    end
end

function BFH:ApplyPosition()
    if not display then return end
    display:ClearAllPoints()
    display:SetPoint(self.db.point or "CENTER", UIParent, self.db.relativePoint or "CENTER",
        self.db.x or 0, self.db.y or 0)
end

function BFH:ApplyDisplaySettings()
    if not display then return end
    local d = self.db
    local size = CELL * Clamp(d.scale, 1, 300) / 100
    display:SetSize(size, size)
    self:ApplyPosition()

    ApplyFontString(counter, d.counter)
    counter:ClearAllPoints()
    counter:SetPoint("CENTER", display, "CENTER", d.counter.x or 0, d.counter.y or 0)

    ApplyFontString(label, d.label)
    label:ClearAllPoints()
    label:SetPoint("CENTER", display, "CENTER", d.label.x or 0, d.label.y or 0)

    ApplyFontString(perfect, d.label)
    perfect:ClearAllPoints()
    perfect:SetPoint("CENTER", display, "CENTER", d.label.x or 0, d.label.y or 0)

    local cs = size * CELEBRATION_RATIO
    celebration.frame:SetSize(cs, cs)

    dragOverlay:SetShown(not d.locked)
    self:UpdateTexts()
end

function BFH:SetLocked(locked)
    self.db.locked = locked and true or false
    if not locked and not self.stage then
        self:StartPreview("SOUL")
    end
    self:ApplyDisplaySettings()
    if self.RefreshConfig then self:RefreshConfig() end
end

---------------------------------------------------------------------------
-- Stage control
---------------------------------------------------------------------------

function BFH:GetStageDuration(stage)
    local limits = self.LIMITS[stage]
    local v = stage == "BLIGHT" and self.db.blightDelay or self.db.soulDelay
    return Clamp(v, limits[1], limits[2])
end

local function AudioAllowed()
    return not BFH.preview or BFH.previewCycle == 1
end

function BFH:ShowStage(stage)
    self.stage = stage
    self.phase = "LOADING"
    local duration = self:GetStageDuration(stage)
    self.stageEnd = GetTime() + duration
    self.lastSpoken = nil
    main:Play(PREFIX[stage] .. "_loading", {
        duration = duration,
        fadeIn = LOADING_FADE,
        onDone = function() BFH:EnterReady() end,
    })
    self:UpdateTexts()
end

function BFH:EnterReady()
    local stage = self.stage
    if not PREFIX[stage] then return end
    self.phase = "READY"
    if AudioAllowed() then self:PlayEvent(stage .. "_READY") end
    main:Play(PREFIX[stage] .. "_ready", {fps = FPS, onDone = function() BFH:EnterIdle() end})
    self:UpdateTexts()
end

function BFH:EnterIdle()
    local stage = self.stage
    if not PREFIX[stage] then return end
    self.phase = "IDLE"
    main:Play(PREFIX[stage] .. "_idle", {fps = FPS, loop = true})
    if self.preview then self.previewNext = GetTime() + PREVIEW_IDLE_TIME end
    self:UpdateTexts()
end

function BFH:GetPutrefyKey(variant)
    return "putrefy_" .. variant .. (self.db.putrefySmall and "_sml" or "_big")
end

function BFH:ShowPutrefy(delay)
    local variants = ns.PutrefyVariants or {"uhly"}
    self.putrefyVariant = variants[math.random(#variants)]
    self.stage = "PUTREFY"
    self.phase = "IDLE"
    self.putrefyExpire = GetTime() + (delay or 0) + PUTREFY_FADE + PUTREFY_TIME
    main:Play(self:GetPutrefyKey(self.putrefyVariant) .. "_idle", {
        fps = FPS,
        loop = true,
        fadeIn = PUTREFY_FADE,
        delay = delay,
    })
    self:UpdateTexts()
end

function BFH:IsPutrefyPending()
    return self.stage == "PUTREFY" and main and main:IsPending()
end

function BFH:PlayOnUse(stage)
    local key
    if stage == "PUTREFY" then
        key = self:GetPutrefyKey(self.putrefyVariant or "uhly") .. "_onuse"
    else
        key = PREFIX[stage] .. "_onuse"
    end
    outro:Play(key, {
        fps = FPS,
        onDone = function()
            outro:Stop()
            BFH:OnOnUseFinished(stage)
        end,
    })
end

-- Pressing Putrefy before its card appears is allowed, so the OnUse waits
-- for the pending delay instead of cutting Blightfall's OnUse short.
function BFH:CastPutrefy()
    local delay = main:PendingTime()
    self:ClearMain()
    self.putrefyToken = (self.putrefyToken or 0) + 1
    local token = self.putrefyToken
    if delay > 0 then
        C_Timer.After(delay, function()
            if BFH.putrefyToken == token then BFH:PlayOnUse("PUTREFY") end
        end)
    else
        self:PlayOnUse("PUTREFY")
    end
end

function BFH:ShowCelebration()
    if not celebration then return end
    celebration:Play("celebration", {
        fps = CELEBRATION_FPS,
        onDone = function() BFH:HideCelebration() end,
    })
    perfect:SetShown(self.db.label.show and true or false)
end

function BFH:HideCelebration()
    if not celebration then return end
    celebration:Stop()
    perfect:Hide()
end

function BFH:PreviewCelebration()
    self:StopCelebration()
    self:StartCelebration()
end

function BFH:ClearMain()
    self:StopTTS()
    self.stage = nil
    self.phase = nil
    self.lastSpoken = nil
    if main then main:Stop() end
    self:UpdateTexts()
end

function BFH:ClearAll()
    self:ClearMain()
    if outro then outro:Stop() end
    self.putrefyToken = (self.putrefyToken or 0) + 1
    self:StopCelebration()
end

---------------------------------------------------------------------------
-- Preview (loops until stopped)
---------------------------------------------------------------------------

function BFH:StartPreview(stage)
    if not display then return end
    self:ClearAll()
    self.preview = stage
    self.previewCycle = 1
    self.previewNext = nil
    if stage == "PUTREFY" then
        self:ShowPutrefy(0)
        self.previewNext = GetTime() + PUTREFY_FADE + PUTREFY_TIME
    else
        self:ShowStage(stage)
    end
end

function BFH:StopPreview()
    if not self.preview then return end
    self.preview = nil
    self.previewNext = nil
    self:ClearAll()
end

local function AdvancePreview()
    local stage = BFH.preview
    BFH.previewNext = nil
    BFH.previewCycle = (BFH.previewCycle or 1) + 1
    BFH:PlayOnUse(stage)
    if stage == "PUTREFY" then
        BFH:ShowPutrefy(0.5)
        BFH.previewNext = GetTime() + 0.5 + PUTREFY_FADE + PUTREFY_TIME
    else
        BFH:ShowStage(stage)
    end
end

---------------------------------------------------------------------------
-- Per-frame update
---------------------------------------------------------------------------

function BFH:FormatRemaining(v)
    v = math.max(v, 0)
    local p = tonumber(self.db.counter.precision) or 1
    if p <= 0 then return tostring(math.ceil(v)) end
    if p == 1 then return string.format("%.1f", v) end
    return string.format("%.2f", v)
end

function BFH:UpdateTexts()
    if not counter then return end
    local d = self.db
    local loading = self.phase == "LOADING"

    counter:SetShown(loading and d.counter.show)

    local showLabel = self.stage and d.label.show and not self:IsPutrefyPending()
    if showLabel then
        label:SetText(d.names[self.stage] or self.DEFAULT_NAMES[self.stage] or "")
    end
    label:SetShown(showLabel and true or false)

end

function BFH:OnDisplayUpdate(elapsed)
    main:Update(elapsed)
    outro:Update(elapsed)
    celebration:Update(elapsed)
    if perfect:IsShown() then
        -- The text blinks; the animation behind it does not.
        perfect:SetAlpha(0.55 + 0.45 * math.sin(GetTime() * math.pi * 5))
    end
    -- Countdown and spell name fade in together with the animation.
    textFrame:SetAlpha(main.frame:IsShown() and main.frame:GetAlpha() or 1)

    if self.preview and self.previewNext and GetTime() >= self.previewNext then
        AdvancePreview()
    elseif not self.preview and self.stage == "SOUL" and self.dtCastTime
        and GetTime() >= self.dtCastTime + SOUL_TIMEOUT then
        self:Debug("Soul Reaper timed out")
        self.dtCastTime = nil
        main:FadeOut(SOUL_FADE_OUT, function() BFH:ClearMain() end)
    elseif not self.preview and self.stage == "PUTREFY" and GetTime() >= (self.putrefyExpire or 0) then
        self:Debug("Putrefy timed out")
        -- Letting the card run out is not a completed combo.
        self:MissCombo("Putrefy never cast")
        self:PlayOnUse("PUTREFY")
        self:ClearMain()
        return
    end

    if self.stage == "PUTREFY" and main.playing and not main:IsPending() and not label:IsShown() and self.db.label.show then
        self:UpdateTexts()
    end

    local loading = self.phase == "LOADING"
    local remaining = loading and (self.stageEnd - GetTime()) or 0

    -- Optional flash (placeholder effect until the designed one arrives):
    -- near the end of loading, and/or the whole time Ready/Idle is up.
    local flash
    if loading then
        flash = self.db.flashEnabled and remaining <= (tonumber(self.db.flashAt) or 4)
    else
        flash = self.stage and self.db.flashReady
    end
    if flash then
        local pulse = 0.5 + 0.5 * math.sin(GetTime() * math.pi * 6)
        main.glow:SetAlpha(0.55 * pulse)
        main.glow:Show()
    elseif main.glow:IsShown() then
        main.glow:Hide()
    end

    if not loading then return end
    counter:SetText(self:FormatRemaining(remaining))

    local maxCount = math.min(10, math.floor(self.db.countdownStart or 4))
    local spoken
    for n = 1, maxCount do
        if remaining <= n then
            spoken = n
            break
        end
    end
    if spoken and self.lastSpoken ~= spoken then
        self.lastSpoken = spoken
        if AudioAllowed() then self:PlayCountdown(spoken) end
    end
end
