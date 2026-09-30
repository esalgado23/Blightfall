local BFH = _G.Blightfall
if not BFH then return end

local WIDTH, HEIGHT = 780, 560
local CONTENT_WIDTH = WIDTH - 70
local COL2 = 370

local controls = {}

local function Track(control)
    controls[#controls + 1] = control
    return control
end

local function Changed()
    BFH:ApplyDisplaySettings()
    BFH:RefreshConfig()
end

---------------------------------------------------------------------------
-- Layout: each page is a scroll child with a running y cursor.
---------------------------------------------------------------------------

local function Advance(page, h)
    page.y = page.y - h
end

local function At(page, widget, x, yOffset)
    widget:SetPoint("TOPLEFT", page, "TOPLEFT", x or 16, page.y + (yOffset or 0))
end

local function Header(page, text)
    Advance(page, 8)
    local fs = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetText(text)
    At(page, fs)
    local line = page:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 0.82, 0, 0.25)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -4)
    line:SetPoint("RIGHT", page, "RIGHT", -16, 0)
    Advance(page, 32)
    return fs
end

local function Note(page, text, x, width)
    local fs = page:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWidth(width or (CONTENT_WIDTH - 40))
    fs:SetText(text)
    At(page, fs, x)
    return fs
end

---------------------------------------------------------------------------
-- Widgets (Blizzard templates)
---------------------------------------------------------------------------

local function Checkbox(parent, text, getter, setter)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    local fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    fs:SetText(text)
    cb.label = fs
    cb:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
        Changed()
    end)
    cb.Refresh = function(self) self:SetChecked(getter() and true or false) end
    return Track(cb)
end

local function Round(v, step)
    return math.floor(v / step + 0.5) * step
end

local function Slider(parent, text, minV, maxV, step, getter, setter, format)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(300, 44)

    local title = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(text)

    local value = wrap:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    value:SetPoint("TOPRIGHT", 0, 0)

    local s = CreateFrame("Slider", nil, wrap, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL")
    s:SetHeight(17)
    s:SetPoint("TOPLEFT", 0, -18)
    s:SetPoint("TOPRIGHT", 0, -18)
    s:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = {left = 3, right = 3, top = 6, bottom = 6},
    })
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s:EnableMouseWheel(true)

    local function Show(v)
        value:SetText(format and format(v) or tostring(v))
    end

    s:SetScript("OnValueChanged", function(self, v)
        v = Round(v, step)
        Show(v)
        if self.refreshing then return end
        setter(v)
        BFH:ApplyDisplaySettings()
    end)
    s:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(math.max(minV, math.min(maxV, self:GetValue() + delta * step)))
    end)

    wrap.slider = s
    wrap.Refresh = function()
        local v = getter()
        s.refreshing = true
        s:SetValue(v)
        s.refreshing = false
        Show(Round(v, step))
    end
    return Track(wrap)
end

-- items: list of {text=, value=} or a function returning one
local function Dropdown(parent, text, width, items, getter, setter)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(width, 46)

    local title = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(text)
    wrap.title = title

    local dd = CreateFrame("DropdownButton", nil, wrap, "WowStyle1DropdownTemplate")
    dd:SetPoint("TOPLEFT", 0, -16)
    dd:SetWidth(width)
    dd:SetupMenu(function(_, root)
        if root.SetScrollMode then root:SetScrollMode(320) end
        local list = type(items) == "function" and items() or items
        for _, item in ipairs(list) do
            root:CreateRadio(item.text,
                function() return getter() == item.value end,
                function()
                    setter(item.value)
                    Changed()
                end)
        end
    end)

    wrap.dropdown = dd
    wrap.Refresh = function() dd:GenerateMenu() end
    return Track(wrap)
end

local function Button(parent, text, width, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 24)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

local function ColorSwatch(parent, text, getter, setter)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(20, 20)

    local border = b:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetColorTexture(0.8, 0.8, 0.8, 1)
    local swatch = b:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("TOPLEFT", 2, -2)
    swatch:SetPoint("BOTTOMRIGHT", -2, 2)

    local fs = b:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", b, "RIGHT", 6, 0)
    fs:SetText(text)

    local function Set(r, g, bb)
        setter({r, g, bb, 1})
        Changed()
    end

    b:SetScript("OnClick", function()
        local c = getter()
        ColorPickerFrame:SetupColorPickerAndShow({
            r = c[1], g = c[2], b = c[3],
            hasOpacity = false,
            swatchFunc = function() Set(ColorPickerFrame:GetColorRGB()) end,
            cancelFunc = function(prev) Set(prev.r, prev.g, prev.b) end,
        })
    end)
    b.Refresh = function()
        local c = getter()
        swatch:SetColorTexture(c[1], c[2], c[3], 1)
    end
    return Track(b)
end

-- Text box with Accept/Cancel while editing and a revert arrow otherwise.
local function NameEditor(parent, text, stage)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(420, 26)

    local fs = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("LEFT", 0, 0)
    fs:SetWidth(90)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)

    local box = CreateFrame("EditBox", nil, wrap, "InputBoxTemplate")
    box:SetSize(170, 22)
    box:SetPoint("LEFT", fs, "RIGHT", 8, 0)
    box:SetAutoFocus(false)
    box:SetMaxLetters(40)

    local accept = Button(wrap, ACCEPT or "Accept", 64)
    accept:SetPoint("LEFT", box, "RIGHT", 6, 0)
    local cancel = Button(wrap, CANCEL or "Cancel", 64)
    cancel:SetPoint("LEFT", accept, "RIGHT", 4, 0)

    local reset = CreateFrame("Button", nil, wrap)
    reset:SetSize(22, 22)
    reset:SetPoint("LEFT", box, "RIGHT", 6, 0)
    reset:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
    reset:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    reset:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset to \"" .. BFH.DEFAULT_NAMES[stage] .. "\"")
        GameTooltip:Show()
    end)
    reset:SetScript("OnLeave", GameTooltip_Hide)

    local function SetEditing(editing)
        accept:SetShown(editing)
        cancel:SetShown(editing)
        reset:SetShown(not editing)
    end

    -- Accept/Cancel stay up until one of them is used, so an unsaved edit
    -- is never lost just because focus moved elsewhere.
    local function Commit()
        local v = strtrim(box:GetText() or "")
        if v == "" then v = BFH.DEFAULT_NAMES[stage] end
        BFH.db.names[stage] = v
        box:ClearFocus()
        SetEditing(false)
        Changed()
    end

    local function Revert()
        box:SetText(BFH.db.names[stage] or BFH.DEFAULT_NAMES[stage])
        box:ClearFocus()
        SetEditing(false)
    end

    box:SetScript("OnEditFocusGained", function() SetEditing(true) end)
    box:SetScript("OnEnterPressed", Commit)
    box:SetScript("OnEscapePressed", Revert)
    accept:SetScript("OnClick", Commit)
    cancel:SetScript("OnClick", Revert)
    reset:SetScript("OnClick", function()
        BFH.db.names[stage] = BFH.DEFAULT_NAMES[stage]
        Changed()
    end)

    SetEditing(false)
    wrap.Refresh = function()
        if not accept:IsShown() then
            box:SetText(BFH.db.names[stage] or BFH.DEFAULT_NAMES[stage])
        end
    end
    return Track(wrap)
end

---------------------------------------------------------------------------
-- Shared option lists
---------------------------------------------------------------------------

local function FontItems()
    local out = {}
    for _, f in ipairs(BFH:GetFonts()) do
        out[#out + 1] = {text = f.name, value = f.path}
    end
    return out
end

local OUTLINES = {
    {text = "None", value = ""},
    {text = "Outline", value = "OUTLINE"},
    {text = "Thick outline", value = "THICKOUTLINE"},
    {text = "Monochrome", value = "MONOCHROME"},
    {text = "Monochrome + outline", value = "MONOCHROME,OUTLINE"},
}

local CHANNELS = {
    {text = "Master", value = "Master"},
    {text = "Sound effects", value = "SFX"},
    {text = "Dialog", value = "Dialog"},
    {text = "Music", value = "Music"},
    {text = "Ambience", value = "Ambience"},
}

local function SoundItems()
    local out = {}
    for _, s in ipairs(BFH.SOUNDS) do
        if not s.hidden then out[#out + 1] = {text = s.name, value = s.key} end
    end
    return out
end

local function PresetItems()
    local out = {}
    for _, p in ipairs(BFH.SOUND_PRESETS) do out[#out + 1] = {text = p.name, value = p.key} end
    out[#out + 1] = {text = "Custom", value = "custom"}
    return out
end

local function FontName(path)
    for _, f in ipairs(BFH:GetFonts()) do
        if f.path == path then return f.name end
    end
    return path
end

-- Font / size / outline / colour / shadow / offset block shared by the
-- countdown and spell-name sections.
local function TextStyleBlock(page, cfg, offsetRange)
    Dropdown(page, "Font", 220, FontItems,
        function() return cfg().font end,
        function(v) cfg().font = v; cfg().fontName = FontName(v) end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Dropdown(page, "Outline", 220, OUTLINES,
        function() return cfg().outline end,
        function(v) cfg().outline = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 56)

    Slider(page, "Size", 6, 64, 1,
        function() return cfg().size end,
        function(v) cfg().size = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    ColorSwatch(page, "Colour",
        function() return cfg().color end,
        function(v) cfg().color = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y - 18)
    Advance(page, 52)

    Checkbox(page, "Shadow",
        function() return cfg().shadow end,
        function(v) cfg().shadow = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    ColorSwatch(page, "Shadow colour",
        function() return cfg().shadowColor end,
        function(v) cfg().shadowColor = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y - 3)
    Advance(page, 36)

    Slider(page, "X offset", -offsetRange, offsetRange, 1,
        function() return cfg().x end,
        function(v) cfg().x = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Slider(page, "Y offset", -offsetRange, offsetRange, 1,
        function() return cfg().y end,
        function(v) cfg().y = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 56)
end

---------------------------------------------------------------------------
-- Pages
---------------------------------------------------------------------------

local function BuildGeneral(page)
    local db = function() return BFH.db end

    local status = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    At(page, status)
    BFH.talentStatusText = status
    Advance(page, 30)

    local move = Button(page, "Move", 110, function()
        BFH:SetLocked(not BFH.db.locked)
    end)
    At(page, move)
    BFH.moveButton = move
    local resetPos = Button(page, "Reset position", 130, function()
        BFH.db.point, BFH.db.relativePoint = "CENTER", "CENTER"
        BFH.db.x, BFH.db.y = 0, 120
        BFH:ApplyPosition()
    end)
    resetPos:SetPoint("LEFT", move, "RIGHT", 8, 0)
    Advance(page, 36)

    Header(page, "Minimap")
    Checkbox(page, "Show minimap button",
        function() return db().showMinimapButton end,
        function(v) db().showMinimapButton = v; BFH:UpdateMinimapButton() end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    local hover = Checkbox(page, "Only show on mouseover",
        function() return db().minimapMouseoverOnly end,
        function(v) db().minimapMouseoverOnly = v; BFH:UpdateMinimapButton() end)
    hover:SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    -- Mouseover only means something while the button is shown.
    local baseRefresh = hover.Refresh
    hover.Refresh = function(self)
        baseRefresh(self)
        local enabled = db().showMinimapButton ~= false
        self:SetEnabled(enabled)
        self.label:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable")
    end
    Advance(page, 36)

    Header(page, "Timers")
    Note(page, "Take your trinket's effect duration into account; your timers should line up with it too.")
    Advance(page, 28)
    Note(page, string.format("Recommended: %.1fs", BFH.RECOMMENDED.SOUL), 16, 300)
    Note(page, string.format("Recommended: %.1fs", BFH.RECOMMENDED.BLIGHT), COL2, 300)
    Advance(page, 18)
    Slider(page, "Soul Reaper after Dark Transformation", 1, 15, 0.1,
        function() return db().soulDelay end,
        function(v) db().soulDelay = v end,
        function(v) return string.format("%.1fs", v) end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Slider(page, "Blightfall after Soul Reaper", 1, 8, 0.1,
        function() return db().blightDelay end,
        function(v) db().blightDelay = v end,
        function(v) return string.format("%.1fs", v) end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 52)
    Checkbox(page, "Show Putrefy after Blightfall",
        function() return db().showPutrefy end,
        function(v) db().showPutrefy = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Advance(page, 36)

    Header(page, "Preview")
    local p1 = Button(page, "Soul Reaper", 130, function() BFH:StartPreview("SOUL") end)
    At(page, p1)
    local p2 = Button(page, "Blightfall", 130, function() BFH:StartPreview("BLIGHT") end)
    p2:SetPoint("LEFT", p1, "RIGHT", 8, 0)
    local p3 = Button(page, "Putrefy", 130, function() BFH:StartPreview("PUTREFY") end)
    p3:SetPoint("LEFT", p2, "RIGHT", 8, 0)
    local stop = Button(page, "Stop", 100, function() BFH:StopPreview() end)
    stop:SetPoint("LEFT", p3, "RIGHT", 8, 0)
    Advance(page, 32)
    Note(page, "Previews loop until you press Stop or close this window. Sounds play on the first loop only.")
    Advance(page, 36)

    local credit = page:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    credit:SetText("Blightfall v" .. BFH.VERSION .. "  -  Created by JSAL")
    At(page, credit)
    Advance(page, 24)
end

local function BuildStyle(page)
    local db = function() return BFH.db end

    Header(page, "Animation")
    local scale = Slider(page, "Size", 1, 300, 1,
        function() return db().scale end,
        function(v) db().scale = v end,
        function(v) return v .. "%" end)
    scale:SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    local x1 = Button(page, "1x", 44, function() db().scale = 100; Changed() end)
    x1:SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y - 14)
    local x2 = Button(page, "2x", 44, function() db().scale = 200; Changed() end)
    x2:SetPoint("LEFT", x1, "RIGHT", 4, 0)
    local x3 = Button(page, "3x", 44, function() db().scale = 300; Changed() end)
    x3:SetPoint("LEFT", x2, "RIGHT", 4, 0)
    Advance(page, 52)

    Checkbox(page, "Small Putrefy cards",
        function() return db().putrefySmall end,
        function(v) db().putrefySmall = v; BFH:PreloadTextures() end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Advance(page, 34)
    Checkbox(page, "Flash near the end of loading",
        function() return db().flashEnabled end,
        function(v) db().flashEnabled = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Slider(page, "Start flashing at", 1, 10, 1,
        function() return db().flashAt end,
        function(v) db().flashAt = v end,
        function(v) return v .. "s left" end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 52)
    Checkbox(page, "Flash while Ready / Idle",
        function() return db().flashReady end,
        function(v) db().flashReady = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Advance(page, 36)

    Header(page, "Countdown text")
    Checkbox(page, "Show countdown while loading",
        function() return db().counter.show end,
        function(v) db().counter.show = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Dropdown(page, "Precision", 220,
        {{text = "Whole seconds", value = 0}, {text = "1 decimal", value = 1}, {text = "2 decimals", value = 2}},
        function() return db().counter.precision end,
        function(v) db().counter.precision = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 56)
    TextStyleBlock(page, function() return db().counter end, 200)

    Header(page, "Spell name")
    Checkbox(page, "Show spell name under the animation",
        function() return db().label.show end,
        function(v) db().label.show = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Advance(page, 36)
    for _, stage in ipairs({"SOUL", "BLIGHT", "PUTREFY"}) do
        NameEditor(page, BFH.DEFAULT_NAMES[stage], stage)
            :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
        Advance(page, 32)
    end
    Advance(page, 8)
    TextStyleBlock(page, function() return db().label end, 200)

    Header(page, "Sounds")
    Dropdown(page, "Preset", 340, PresetItems,
        function() return BFH:GetMatchingPreset() end,
        function(v) if v ~= "custom" then BFH:ApplySoundPreset(v) end end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Advance(page, 56)

    local function EventDropdown(parent, event, x)
        local dd = Dropdown(parent, BFH.SOUND_EVENT_NAMES[event], 220, SoundItems,
            function() return db().sounds[event] end,
            function(v)
                db().sounds[event] = v
                BFH:PlaySoundEntry(v)
            end)
        dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x, parent.y)
        return dd
    end

    EventDropdown(page, "SOUL_READY", 16)
    EventDropdown(page, "BLIGHT_READY", COL2)
    Advance(page, 56)
    Note(page, "Changing a sound switches the preset to Custom.")
    Advance(page, 30)

    Checkbox(page, "Burning card sound when a Putrefy card is used",
        function() return db().cardBurn end,
        function(v) db().cardBurn = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Advance(page, 26)
    Note(page, "Plays as the card burns, one of four sounds picked at random. Combo presets use their own audio instead.", 34)
    Advance(page, 32)

    Dropdown(page, "Sound channel", 220, CHANNELS,
        function() return db().soundChannel end,
        function(v) db().soundChannel = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Slider(page, "Channel volume", 0, 100, 1,
        function() return BFH:GetChannelVolume() end,
        function(v) BFH:SetChannelVolume(v) end,
        function(v) return v .. "%" end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 52)
    Note(page, "Blizzard only lets an addon set a channel's level, not one effect's volume, so this slider is WoW's own volume for the channel above and affects the rest of the game too.")
    Advance(page, 46)

    Header(page, "Spoken countdown")
    Checkbox(page, "Spoken countdown",
        function() return db().soundEnabled end,
        function(v) db().soundEnabled = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 12, page.y)
    Slider(page, "Starts at", 1, 10, 1,
        function() return db().countdownStart end,
        function(v) db().countdownStart = v end,
        function(v) return v .. "s" end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 52)
    Dropdown(page, "Voice", 220,
        {{text = "Voice files (1-10)", value = "FILES"}, {text = "WoW text-to-speech", value = "TTS"}},
        function() return db().audioMode end,
        function(v) db().audioMode = v; if v ~= "TTS" then BFH:StopTTS() end end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Advance(page, 56)
    Slider(page, "Text-to-speech volume", 0, 100, 1,
        function() return db().ttsVolume end,
        function(v) db().ttsVolume = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    Slider(page, "Text-to-speech speed", -10, 10, 1,
        function() return db().ttsRate end,
        function(v) db().ttsRate = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y)
    Advance(page, 52)
    Dropdown(page, "Text-to-speech voice", 220,
        function()
            local out = {}
            for _, v in ipairs(BFH:GetTTSVoices()) do out[#out + 1] = {text = v.name, value = v.voiceID} end
            return out
        end,
        function() return BFH:GetTTSVoiceID() end,
        function(v) db().ttsVoiceID = v end)
        :SetPoint("TOPLEFT", page, "TOPLEFT", 16, page.y)
    local test = Button(page, "Test voice", 110, function() BFH:SpeakText("3, 2, 1") end)
    test:SetPoint("TOPLEFT", page, "TOPLEFT", COL2, page.y - 16)
    Advance(page, 60)

    -- Everything below belongs to combo presets only, so it lives in its own
    -- frame that is hidden outright instead of greyed out.
    local combo = CreateFrame("Frame", nil, page)
    combo:SetPoint("TOPLEFT", page, "TOPLEFT", 0, page.y)
    combo:SetWidth(CONTENT_WIDTH)
    combo.y = 0

    Header(combo, "Combo sounds")
    EventDropdown(combo, "SOUL_END", 16)
    EventDropdown(combo, "BLIGHT_END", COL2)
    Advance(combo, 56)
    EventDropdown(combo, "PUTREFY_END", 16)
    Advance(combo, 56)

    Header(combo, "Perfect Combo")
    Note(combo, "Cast every spell at or after its Ready and the sequence ends with a celebration.")
    Advance(combo, 32)
    Checkbox(combo, "Perfect Combo celebration",
        function() return db().celebrationEnabled end,
        function(v) db().celebrationEnabled = v end)
        :SetPoint("TOPLEFT", combo, "TOPLEFT", 12, combo.y)
    Advance(combo, 26)
    local warn = Note(combo, "WARNING: turning this off will make you do 10% less dps.", 34)
    warn:SetTextColor(1, 0.3, 0.25)
    Advance(combo, 18)
    local joke = Note(combo, "(Or at least it will feel like it.)", 34)
    joke:SetTextColor(0.6, 0.6, 0.65)
    Advance(combo, 30)
    Checkbox(combo, "Turn it off in Mythic+ and Mythic raid",
        function() return db().celebrationOffInstances end,
        function(v) db().celebrationOffInstances = v end)
        :SetPoint("TOPLEFT", combo, "TOPLEFT", 12, combo.y)
    Advance(combo, 36)
    -- The finale's sound is part of the preset, not something to swap out.
    local celPreview = Button(combo, "Preview celebration", 160, function()
        BFH:PreviewCelebration()
    end)
    celPreview:SetPoint("TOPLEFT", combo, "TOPLEFT", 16, combo.y)
    Advance(combo, 42)

    combo:SetHeight(-combo.y)
    page.comboSection = combo
    page.comboHeight = -combo.y
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

local function CreatePage(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -28, 6)
    local page = CreateFrame("Frame", nil, scroll)
    page:SetSize(CONTENT_WIDTH, 100)
    page.y = -10
    scroll:SetScrollChild(page)
    scroll.page = page
    return scroll
end

function BFH:InitializeConfig()
    if self.config then return end

    local f = CreateFrame("Frame", "BlightfallConfig", UIParent, "ButtonFrameTemplate")
    if ButtonFrameTemplate_HidePortrait then ButtonFrameTemplate_HidePortrait(f) end
    if ButtonFrameTemplate_HideButtonBar then ButtonFrameTemplate_HideButtonBar(f) end
    f:SetSize(WIDTH, HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    if f.SetTitle then f:SetTitle(BFH.FULL_NAME) elseif f.TitleText then f.TitleText:SetText(BFH.FULL_NAME) end
    f:Hide()
    tinsert(UISpecialFrames, "BlightfallConfig")

    -- The template's X goes through Blizzard's panel manager (HideUIPanel),
    -- which doesn't reliably close addon windows. Close it directly.
    f.onCloseCallback = function() f:Hide() end
    if f.CloseButton then
        f.CloseButton:SetScript("OnClick", function() f:Hide() end)
    end

    local inset = f.Inset or f
    local general = CreatePage(inset)
    local style = CreatePage(inset)
    BuildGeneral(general.page)
    BuildStyle(style.page)
    general.page:SetHeight(-general.page.y + 10)
    style.page:SetHeight(-style.page.y + 10)
    style.page.baseHeight = -style.page.y + 10
    f.stylePage = style.page
    f.pages = {general, style}

    local names = {"General", "Style"}
    f.Tabs = {}
    for i, name in ipairs(names) do
        local tab = CreateFrame("Button", "BlightfallConfigTab" .. i, f, "PanelTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(name)
        if i == 1 then
            tab:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 12, 2)
        else
            tab:SetPoint("LEFT", f.Tabs[i - 1], "RIGHT", 4, 0)
        end
        tab:SetScript("OnClick", function(self) BFH:ShowConfigPage(self:GetID()) end)
        if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
        f.Tabs[i] = tab
    end
    PanelTemplates_SetNumTabs(f, #names)

    f:SetScript("OnShow", function()
        BFH:RefreshConfig()
        -- Show an animation right away so it can be positioned and styled.
        if not BFH.stage then BFH:StartPreview("SOUL") end
    end)
    f:SetScript("OnHide", function()
        BFH:StopPreview()
        if not BFH.db.locked then BFH:SetLocked(true) end
    end)

    self.config = f
    self:ShowConfigPage(1)
end

function BFH:ShowConfigPage(id)
    local f = self.config
    for i, page in ipairs(f.pages) do page:SetShown(i == id) end
    PanelTemplates_SetTab(f, id)
end

function BFH:RefreshConfig()
    if not self.config or not self.config:IsShown() then return end
    for _, c in ipairs(controls) do
        if c.Refresh then c:Refresh() end
    end
    if self.talentStatusText then
        local function Mark(known) return known and "|cff45ff45known|r" or "|cffff4040not known|r" end
        self.talentStatusText:SetText("Talents:  Soul Reaper " .. Mark(self:HasSoulReaper())
            .. "   Blightfall " .. Mark(self:HasBlightfall())
            .. "   Putrefy " .. Mark(self:HasPutrefy()))
    end
    local sp = self.config.stylePage
    if sp and sp.comboSection then
        local on = self.comboMode and true or false
        sp.comboSection:SetShown(on)
        sp:SetHeight(sp.baseHeight + (on and sp.comboHeight or 0))
    end
    if self.moveButton then
        self.moveButton:SetText(self.db.locked and "Move" or "Lock")
    end
end

function BFH:ToggleConfig()
    self:InitializeConfig()
    self.config:SetShown(not self.config:IsShown())
end
