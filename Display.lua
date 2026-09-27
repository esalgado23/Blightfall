local BFH = _G.Blightfall
if not BFH then return end

local display, bg, iconFrame, iconBorderFrame, icon, status, barBorderFrame, barBG, spark, label, timer, iconTimer, dragOverlay

local function Clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function BFH:InitializeDisplay()
    display = CreateFrame("Frame", "BlightfallDisplay", UIParent)
    display:SetFrameStrata("HIGH")
    display:SetClampedToScreen(true)
    display:SetMovable(true)
    display:Hide()
    self.display = display

    bg = CreateFrame("Frame", nil, display, "BackdropTemplate")
    bg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    -- Keep the spell icon on its own higher frame level so background opacity
    -- never darkens or hides it, even at 100%.
    iconFrame = CreateFrame("Frame", nil, display)
    iconFrame:SetFrameLevel(display:GetFrameLevel() + 5)

    iconBorderFrame = CreateFrame("Frame", nil, display, "BackdropTemplate")
    iconBorderFrame:SetFrameLevel(display:GetFrameLevel() + 4)

    icon = iconFrame:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints(iconFrame)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    status = CreateFrame("StatusBar", nil, display)
    status:SetFrameLevel(display:GetFrameLevel() + 2)

    barBorderFrame = CreateFrame("Frame", nil, display, "BackdropTemplate")
    barBorderFrame:SetFrameLevel(display:GetFrameLevel() + 1)
    status:SetStatusBarTexture(self.db and self.db.barTexture or "Interface\\TargetingFrame\\UI-StatusBar")

    barBG = status:CreateTexture(nil, "BACKGROUND")
    barBG:SetAllPoints(status)
    barBG:SetTexture("Interface\\Buttons\\WHITE8X8")

    -- Tiny marker only; this replaces the oversized glow/spark.
    spark = status:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    spark:SetVertexColor(1, 1, 1, 0.40)
    spark:SetWidth(2)

    label = status:CreateFontString(nil, "OVERLAY")
    label:SetJustifyH("LEFT")

    timer = status:CreateFontString(nil, "OVERLAY")
    timer:SetJustifyH("RIGHT")

    iconTimer = display:CreateFontString(nil, "OVERLAY")
    iconTimer:SetJustifyH("CENTER")

    dragOverlay = CreateFrame("Frame", nil, display, "BackdropTemplate")
    dragOverlay:SetAllPoints(display)
    dragOverlay:SetFrameLevel(display:GetFrameLevel() + 20)
    dragOverlay:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2})
    dragOverlay:SetBackdropBorderColor(0.62, 0.11, 1, 1)
    dragOverlay:EnableMouse(true)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:SetMovable(true)
    dragOverlay:Hide()

    dragOverlay:SetScript("OnDragStart", function()
        if not BFH.db.locked then display:StartMoving() end
    end)

    dragOverlay:SetScript("OnDragStop", function()
        display:StopMovingOrSizing()
        local p, _, rp, x, y = display:GetPoint(1)
        BFH.db.point, BFH.db.relativePoint, BFH.db.x, BFH.db.y = p, rp, x, y
    end)

    display:SetScript("OnUpdate", function(_, elapsed) BFH:OnDisplayUpdate(elapsed) end)
    self:ApplyDisplaySettings()
end

function BFH:ApplyPosition()
    if not display then return end
    display:ClearAllPoints()
    display:SetPoint(
        self.db.point or "CENTER",
        UIParent,
        self.db.relativePoint or "CENTER",
        self.db.x or 0,
        self.db.y or 0
    )
end

function BFH:ApplyDisplaySettings()
    if not display then return end
    local d = self.db

    status:SetStatusBarTexture(d.barTexture or "Interface\\TargetingFrame\\UI-StatusBar")
    if status.SetReverseFill then
        status:SetReverseFill(d.barReverseFill and true or false)
    end

    display:SetScale(Clamp(d.scale, 0.5, 2.0))
    self:ApplyPosition()

    bg:ClearAllPoints()
    iconFrame:ClearAllPoints()
    iconBorderFrame:ClearAllPoints()
    status:ClearAllPoints()
    barBorderFrame:ClearAllPoints()
    label:ClearAllPoints()
    timer:ClearAllPoints()
    iconTimer:ClearAllPoints()

    local alpha = Clamp(d.backgroundAlpha, 0, 1)
    local barBorderSize = Clamp(d.barBorderSize or 1, 0, 8)
    local iconBorderSize = Clamp(d.iconBorderSize or 1, 0, 8)
    local bbc = d.barBorderColor or {0,0,0,1}
    local ibc = d.iconBorderColor or {0,0,0,1}

    barBorderFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = math.max(1, barBorderSize),
    })
    barBorderFrame:SetBackdropBorderColor(bbc[1], bbc[2], bbc[3], d.barBorderEnabled and (bbc[4] or 1) or 0)

    iconBorderFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = math.max(1, iconBorderSize),
    })
    iconBorderFrame:SetBackdropBorderColor(ibc[1], ibc[2], ibc[3], d.iconBorderEnabled and (ibc[4] or 1) or 0)

    local bc = d.barBackgroundColor or {0.018, 0.018, 0.022, 1}
    bg:SetBackdropColor(bc[1], bc[2], bc[3], alpha)
    bg:SetBackdropBorderColor(0, 0, 0, d.borderEnabled and 1 or 0)
    barBG:SetVertexColor(bc[1], bc[2], bc[3], alpha)

    local font = d.font or "Fonts\\FRIZQT__.TTF"
    if not label:SetFont(font, Clamp(d.labelFontSize, 8, 32), "OUTLINE") then
        font = "Fonts\\FRIZQT__.TTF"
        d.font = font
        d.fontName = "Friz Quadrata"
        label:SetFont(font, Clamp(d.labelFontSize, 8, 32), "OUTLINE")
    end
    timer:SetFont(font, Clamp(d.timerFontSize, 8, 32), "OUTLINE")
    iconTimer:SetFont(font, Clamp(d.iconCountdownFontSize or d.timerFontSize, 8, 48), "OUTLINE")
    local ict = d.iconCountdownColor or {1,1,1,1}
    iconTimer:SetTextColor(ict[1], ict[2], ict[3], ict[4] or 1)

    if d.displayMode == "ICON" then
        local s = Clamp(d.iconOnlySize, 32, 128)
        display:SetSize(s, s + 30)

        bg:SetPoint("TOP", display, "TOP")
        bg:SetSize(s, s)

        iconFrame:SetPoint("TOP", display, "TOP")
        iconFrame:SetSize(s, s)
        iconFrame:Show()
        icon:Show()

        iconBorderFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -(d.iconBorderSize or 1), (d.iconBorderSize or 1))
        iconBorderFrame:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", (d.iconBorderSize or 1), -(d.iconBorderSize or 1))
        iconBorderFrame:Show()
        barBorderFrame:Hide()

        status:Hide()
        label:Hide()
        timer:Hide()

        if d.iconCountdownPosition == "CENTER" then
            iconTimer:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
        else
            iconTimer:SetPoint("TOP", iconFrame, "BOTTOM", 0, -4)
        end
        iconTimer:Show()
    elseif d.displayMode == "TEXT" or d.displayMode == "Text Only" then
        -- Text-only mode: no progress bar and no spell icon.
        iconFrame:Hide()
        iconBorderFrame:Hide()
        icon:Hide()
        status:Hide()
        barBorderFrame:Hide()
        barBG:Hide()
        spark:Hide()
        iconTimer:Hide()

        local tw = (d.textOnlyWidth or 220) * (d.scale or 1)
        local th = (d.textOnlyHeight or 34) * (d.scale or 1)
        display:SetSize(tw, th)

        label:ClearAllPoints()
        timer:ClearAllPoints()
        label:SetPoint("LEFT", display, "LEFT", 0, 0)
        timer:SetPoint("RIGHT", display, "RIGHT", 0, 0)
        label:Show()
        timer:Show()
    else
        local bw = Clamp(d.barWidth, 100, 500)
        local bh = Clamp(d.barHeight, 10, 60)
        local iw = d.showIcon and Clamp(d.iconSize, 10, 80) or 0

        display:SetSize(bw + iw, math.max(bh, iw))
        bg:SetAllPoints(display)

        status:SetSize(bw, bh)
        status:Show()

        if d.showIcon then
            iconFrame:SetSize(iw, iw)
            iconFrame:Show()
            icon:Show()

            if d.iconPosition == "RIGHT" then
                status:SetPoint("LEFT", display, "LEFT", 0, 0)
                iconFrame:SetPoint("LEFT", status, "RIGHT", 0, 0)
            else
                iconFrame:SetPoint("LEFT", display, "LEFT", 0, 0)
                status:SetPoint("LEFT", iconFrame, "RIGHT", 0, 0)
            end

            iconBorderFrame:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -(d.iconBorderSize or 1), (d.iconBorderSize or 1))
            iconBorderFrame:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", (d.iconBorderSize or 1), -(d.iconBorderSize or 1))
            iconBorderFrame:Show()
        else
            iconFrame:Hide()
            iconBorderFrame:Hide()
            status:SetPoint("LEFT", display, "LEFT", 0, 0)
        end

        barBorderFrame:SetPoint("TOPLEFT", status, "TOPLEFT", -(d.barBorderSize or 1), (d.barBorderSize or 1))
        barBorderFrame:SetPoint("BOTTOMRIGHT", status, "BOTTOMRIGHT", (d.barBorderSize or 1), -(d.barBorderSize or 1))
        barBorderFrame:Show()

        if d.showBarText then
            local pos = d.barTextPosition or "LEFT"

            if pos == "CENTER" then
                label:SetPoint("CENTER", status, "CENTER", 0, 0)
                label:SetJustifyH("CENTER")
                timer:Hide()
            elseif pos == "RIGHT" then
                label:SetPoint("RIGHT", status, "RIGHT", -6, 0)
                label:SetJustifyH("RIGHT")
                timer:SetPoint("LEFT", status, "LEFT", 6, 0)
                timer:SetJustifyH("LEFT")
                timer:Show()
            else
                label:SetPoint("LEFT", status, "LEFT", 6, 0)
                label:SetJustifyH("LEFT")
                timer:SetPoint("RIGHT", status, "RIGHT", -6, 0)
                timer:SetJustifyH("RIGHT")
                timer:Show()
            end

            label:Show()
        else
            label:Hide()
            timer:Hide()
        end

        iconTimer:Hide()
    end

    spark:SetShown(d.showSpark and d.displayMode == "BAR")
    dragOverlay:SetShown(not d.locked)
end

function BFH:GetStageDuration(stage)
    if stage == "BLIGHT" then return self.db.blightDelay end
    if stage == "PUTREFY" then return self.db.putrefyDelay end
    return self.db.soulDelay
end

local function SetBarColor(stage, remaining)
    if not status then return end

    local d = BFH.db
    local c
    if remaining < 4 then
        c = d.dangerColor or {0xFF/255, 0x00/255, 0x10/255, 1}
    elseif stage == "BLIGHT" then
        c = d.blightColor or {0x9F/255, 0x1C/255, 0xFF/255, 1}
    elseif stage == "PUTREFY" then
        c = d.putrefyColor or {0x45/255, 0xFF/255, 0x1C/255, 1}
    else
        c = d.soulColor or {0x1C/255, 0x28/255, 0xFF/255, 1}
    end

    status:SetStatusBarColor(c[1], c[2], c[3], c[4] or 1)
end

function BFH:StartStage(stage, duration, preview)
    if not self.db.enabled and not preview then return end
    if not preview then
        if self.IsDisabledByInstance and self:IsDisabledByInstance() then return end
        if stage == "SOUL" and not self.db.enableSoulReaperBar then return end
        if stage == "BLIGHT" and not self.db.enableBlightfallBar then return end
        if stage == "PUTREFY" and not self.db.enablePutrefyBar then return end
    end

    -- Combat timers must belong to a currently armed Dark Transformation
    -- sequence. Preview mode is exempt.
    if not preview and (not self.sequenceArmed or self.sequenceExpired) then
        return
    end

    self.stage = stage
    self.preview = preview and true or false
    self.previewStage = self.preview and stage or nil
    self.stageDuration = Clamp(duration or 7, 0.5, 20)
    self.startTime = GetTime()
    self.endTime = self.startTime + self.stageDuration
    self.lastSpoken = nil
    self.visualRemaining = self.stageDuration

    local spellID, text
    if stage == "BLIGHT" then
        spellID, text = self.SPELL.BLIGHTFALL, "Blightfall"
    elseif stage == "PUTREFY" then
        spellID, text = self.SPELL.PUTREFY, "Putrefy"
    else
        spellID, text = self.SPELL.SOUL_REAPER, "Soul Reaper"
    end

    icon:SetTexture(self:GetSpellTexture(spellID))
    label:SetText(text)
    status:SetMinMaxValues(0, self.stageDuration)
    status:SetValue(self.stageDuration)

    self:ApplyDisplaySettings()
    SetBarColor(stage, self.stageDuration)
    display:Show()
end

function BFH:StopStage(preservePreviewLoop)
    self:StopTTS()

    if not preservePreviewLoop then
        self.preview = nil
        self.previewStage = nil
        self.previewAudioFirstCycle = nil
    end

    self.stage = nil
    self.lastSpoken = nil

    if display then display:Hide() end
end

function BFH:ShowPreview(stage)
    stage = stage or "SOUL"
    self.preview = true
    self.previewStage = stage
    self.previewAudioFirstCycle = true

    self:StartStage(stage, self:GetStageDuration(stage), true)
end

function BFH:FormatRemaining(v)
    v = math.max(v, 0)
    local p = tonumber(self.db.precision) or 1
    if p <= 0 then return tostring(math.ceil(v)) end
    if p == 1 then return string.format("%.1f", v) end
    return string.format("%.2f", v)
end

function BFH:OnDisplayUpdate(elapsed)
    if not self.stage or not self.endTime then return end

    local remaining = self.endTime - GetTime()
    if remaining <= 0 then
        if self.preview and self.previewStage then
            -- Preview mode is intentionally endless: restart the same visual
            -- timer so users can position it and compare bar/icon styles
            -- without repeatedly clicking Preview.
            local stage = self.previewStage
            local duration = self:GetStageDuration(stage)

            -- The first preview playback demonstrates the selected countdown
            -- audio. Repeating preview cycles are visual-only.
            self.previewAudioFirstCycle = false
            self:StartStage(stage, duration, true)
            return
        end

        self:StopStage()
        return
    end

    if self.db.barSmooth then
        local current = self.visualRemaining or remaining
        current = current + (remaining - current) * math.min(1, (elapsed or 0.016) * 14)
        self.visualRemaining = current
        status:SetValue(current)
    else
        self.visualRemaining = remaining
        status:SetValue(remaining)
    end

    local text = self:FormatRemaining(remaining)
    timer:SetText(text)
    iconTimer:SetText(text)
    SetBarColor(self.stage, remaining)

    if self.db.showSpark and self.db.displayMode == "BAR" and status:IsShown() then
        local fraction = math.max(0, math.min(1, remaining / self.stageDuration))
        spark:ClearAllPoints()
        spark:SetPoint("CENTER", status, "LEFT", status:GetWidth() * fraction, 0)
        spark:SetHeight(math.max(4, status:GetHeight() - 6))
    end

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
        if not self.preview or self.previewAudioFirstCycle then
            self:PlayCountdown(spoken)
        end
    end
end
