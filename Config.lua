local BFH = _G.Blightfall
if not BFH then return end

local ACCENT = {0.62, 0.11, 1}
local BG = {0.025, 0.027, 0.034, 0.985}
local PANEL = {0.052, 0.055, 0.066, 0.98}

local function SyncTheme()
    if BFH.db then
        local a = BFH.db.menuAccentColor or ACCENT
        ACCENT[1], ACCENT[2], ACCENT[3] = a[1], a[2], a[3]
        local b = BFH.db.menuBackgroundColor or BG
        BG[1], BG[2], BG[3], BG[4] = b[1], b[2], b[3], b[4] or 1
        local p = BFH.db.menuPanelColor or PANEL
        PANEL[1], PANEL[2], PANEL[3], PANEL[4] = p[1], p[2], p[3], p[4] or 1
    end
end
local MUTED = {0.58, 0.61, 0.69}
local WHITE = {0.94, 0.95, 0.98}

local function Backdrop(frame, color)
    frame:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    frame:SetBackdropColor(unpack(color or PANEL))
    frame:SetBackdropBorderColor(0.15, 0.16, 0.19, 1)
end

local function FS(parent, text, size, color)
    local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local fontPath = (BFH.db and BFH.db.font) or "Fonts\\FRIZQT__.TTF"
    if not f:SetFont(fontPath, size or 12, "") then
        f:SetFont("Fonts\\FRIZQT__.TTF", size or 12, "")
    end
    BFH.configFontStrings = BFH.configFontStrings or {}
    table.insert(BFH.configFontStrings, {obj=f, size=size or 12})
    f:SetText(text or "")
    if color then f:SetTextColor(unpack(color)) end
    return f
end

local function AddTooltip(widget, title, body)
    widget:EnableMouse(true)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title, 1, 1, 1)
        GameTooltip:AddLine(body, 0.82, 0.84, 0.90, true)
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function HelpIcon(parent, x, y, title, body)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(18, 18)
    b:SetPoint("TOPLEFT", x, y)
    b:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    b:SetBackdropColor(0.10,0.105,0.12,1)
    b:SetBackdropBorderColor(0.25,0.26,0.30,1)
    local t = FS(b, "?", 12, {0.82,0.84,0.90})
    t:SetPoint("CENTER")
    AddTooltip(b, title, body)
    return b
end

local function HelpBeside(parent, control, title, body, xOffset, yOffset)
    local b = HelpIcon(parent, 0, 0, title, body)
    b:ClearAllPoints()

    local target = control
    if control and control.text then
        target = control.text
    end

    if target then
        b:SetPoint("LEFT", target, "RIGHT", xOffset or 8, yOffset or 0)
    else
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    end

    return b
end


local function AccentCloseButton(parent, onClick, size)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(size or 36, size or 36)
    Backdrop(b, {0.075,0.078,0.092,1})

    local x = b:CreateFontString(nil, "OVERLAY")
    x:SetFont("Fonts\\FRIZQT__.TTF", math.floor((size or 36) * 0.48), "OUTLINE")
    x:SetText("X")
    x:SetPoint("CENTER", 0, 0)
    b.closeText = x

    local function ApplyAccent()
        local c = BFH.db and BFH.db.menuAccentColor or {0.62,0.11,1,1}
        local r,g,bl,a = c[1] or 0.62, c[2] or 0.11, c[3] or 1, c[4] or 1
        x:SetTextColor(r,g,bl,a)
        b:SetBackdropBorderColor(r,g,bl,0.85)
    end
    b.UpdateAccent = ApplyAccent
    ApplyAccent()

    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self)
        self.closeText:SetTextColor(1,1,1,1)
    end)
    b:SetScript("OnLeave", function(self)
        self:UpdateAccent()
    end)

    BFH.closeButtons = BFH.closeButtons or {}
    table.insert(BFH.closeButtons, b)
    return b
end

local function Button(parent, text, w, h, onClick)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(w or 120, h or 28)
    Backdrop(b, {0.075,0.078,0.092,1})
    local t = FS(b, text, 12, WHITE)
    t:SetPoint("CENTER")
    b.label = t
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(ACCENT)) end)
    b:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.15,0.16,0.19,1) end)
    return b
end

local function Checkbox(parent, label, getter, setter)
    local b = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    b:SetSize(20, 20)
    b:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    b:SetBackdropColor(0.05,0.055,0.065,1)
    b:SetBackdropBorderColor(0.3,0.31,0.35,1)

    local mark = b:CreateTexture(nil, "ARTWORK")
    mark:SetPoint("CENTER")
    mark:SetSize(12,12)
    mark:SetColorTexture(unpack(ACCENT))
    b.mark = mark

    local txt = FS(parent, label, 12, {0.9,0.91,0.94})
    txt:SetPoint("LEFT", b, "RIGHT", 10, 0)
    b.text = txt

    function b:Refresh()
        mark:SetShown(getter())
    end

    b:SetScript("OnClick", function()
        setter(not getter())
        b:Refresh()
        BFH:RefreshConfig()
    end)

    return b
end

local function Slider(parent, label, minv, maxv, step, getter, setter, format)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(300, 50)

    local l = FS(wrap, label, 11, {0.73,0.76,0.82})
    l:SetPoint("TOPLEFT", 0, 0)

    local val = FS(wrap, "", 11, {0.78,0.38,1})
    val:SetPoint("TOPRIGHT", 0, 0)

    local s = CreateFrame("Slider", nil, wrap, "BackdropTemplate")
    s:SetPoint("TOPLEFT", 0, -21)
    s:SetPoint("TOPRIGHT", 0, -21)
    s:SetHeight(12)
    s:SetOrientation("HORIZONTAL")
    s:SetMinMaxValues(minv,maxv)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    s:SetBackdropColor(0.04,0.045,0.055,1)
    s:SetBackdropBorderColor(0.22,0.23,0.27,1)

    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ACCENT))
    thumb:SetSize(10,22)
    s:SetThumbTexture(thumb)

    local changing

    function wrap:Refresh()
        changing = true
        local v = getter()
        s:SetValue(v)
        val:SetText(format and format(v) or tostring(v))
        changing = false
    end

    s:SetScript("OnValueChanged", function(_, v)
        if changing then return end
        v = math.floor((v / step) + 0.5) * step
        setter(v)
        val:SetText(format and format(v) or tostring(v))
        BFH:ApplyDisplaySettings()
    end)

    return wrap
end

local function Dropdown(parent, label, options, getter, setter, onChange)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(300, 54)

    local l = FS(wrap, label, 11, {0.73,0.76,0.82})
    l:SetPoint("TOPLEFT", 0, 0)

    local b = Button(wrap, "", 300, 28, nil)
    b:SetPoint("TOPLEFT", 0, -19)

    b:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            for _, opt in ipairs(options) do
                rootDescription:CreateRadio(
                    opt.text,
                    function() return getter() == opt.value end,
                    function()
                        setter(opt.value)
                        wrap:Refresh()
                        BFH:ApplyDisplaySettings()
                        if onChange then onChange(opt.value) end
                        BFH:RefreshConfig()
                    end
                )
            end
        end)
    end)

    function wrap:Refresh()
        local v = getter()
        local text = tostring(v)
        for _, opt in ipairs(options) do
            if opt.value == v then text = opt.text break end
        end
        b.label:SetText(text)
    end

    return wrap
end

local function PageTitle(page, titleText, desc)
    local t = FS(page, titleText, 22, WHITE)
    t:SetPoint("TOPLEFT", 28, -28)

    local d = FS(page, desc, 11, MUTED)
    d:SetPoint("TOPLEFT", 30, -58)
end

local function MakeScrollablePage(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(700, 1160)
    scroll:SetScrollChild(child)

    scroll:SetScript("OnSizeChanged", function(_, width)
        child:SetWidth(math.max(640, width - 32))
    end)

    return child
end

-- Font discovery: WoW defaults + LibSharedMedia + optional local copies.
BFH.localFontCandidates = {
    {"Arial Bold", "Interface\\AddOns\\Blightfall\\Fonts\\Arial Bold.ttf"},
    {"Arial Narrow", "Interface\\AddOns\\Blightfall\\Fonts\\Arial Narrow.ttf"},
    {"Avant Garde Naowh", "Interface\\AddOns\\Blightfall\\Fonts\\Avant Garde Naowh.ttf"},
    {"Barlow Condensed", "Interface\\AddOns\\Blightfall\\Fonts\\Barlow Condensed.ttf"},
    {"Changa", "Interface\\AddOns\\Blightfall\\Fonts\\Changa.ttf"},
    {"Cinzel Decorative", "Interface\\AddOns\\Blightfall\\Fonts\\Cinzel Decorative.ttf"},
    {"Exo", "Interface\\AddOns\\Blightfall\\Fonts\\Exo.otf"},
    {"Expressway Bold", "Interface\\AddOns\\Blightfall\\Fonts\\Expressway Bold.ttf"},
    {"Expressway", "Interface\\AddOns\\Blightfall\\Fonts\\Expressway.ttf"},
    {"FiraSans Bold", "Interface\\AddOns\\Blightfall\\Fonts\\FiraSans Bold.ttf"},
    {"FiraSans Light", "Interface\\AddOns\\Blightfall\\Fonts\\FiraSans Light.ttf"},
    {"FiraSans Medium", "Interface\\AddOns\\Blightfall\\Fonts\\FiraSans Medium.ttf"},
    {"Future X Black", "Interface\\AddOns\\Blightfall\\Fonts\\Future X Black.otf"},
    {"Gotham Narrow Ultra", "Interface\\AddOns\\Blightfall\\Fonts\\Gotham Narrow Ultra.ttf"},
    {"Gotham Narrow", "Interface\\AddOns\\Blightfall\\Fonts\\Gotham Narrow.otf"},
    {"Homespun", "Interface\\AddOns\\Blightfall\\Fonts\\Homespun.ttf"},
    {"KMT Kimberley", "Interface\\AddOns\\Blightfall\\Fonts\\KMT Kimberley.otf"},
    {"KMT Ninja Naruto", "Interface\\AddOns\\Blightfall\\Fonts\\KMT Ninja Naruto.ttf"},
    {"Poppins", "Interface\\AddOns\\Blightfall\\Fonts\\Poppins.ttf"},
    {"Russo One", "Interface\\AddOns\\Blightfall\\Fonts\\Russo One.ttf"},
    {"Ubuntu", "Interface\\AddOns\\Blightfall\\Fonts\\Ubuntu.ttf"},
}

function BFH:GetAvailableFonts()
    local result = {}
    local seenNames = {}

    local function Add(name, path)
        if type(name) ~= "string" or type(path) ~= "string" then return end
        if seenNames[name] then return end
        seenNames[name] = true
        result[#result + 1] = {name = name, path = path}
    end

    -- These are always available in WoW.
    Add("Friz Quadrata", "Fonts\\FRIZQT__.TTF")
    Add("Arial Narrow", "Fonts\\ARIALN.TTF")
    Add("Morpheus", "Fonts\\MORPHEUS.TTF")
    Add("Skurri", "Fonts\\SKURRI.TTF")

    -- Pull in LibSharedMedia fonts if another addon (such as WeakAuras) has loaded it.
    local libStub = _G.LibStub
    if libStub and type(libStub.GetLibrary) == "function" then
        local ok, lsm = pcall(libStub.GetLibrary, libStub, "LibSharedMedia-3.0", true)
        if ok and lsm and type(lsm.HashTable) == "function" then
            local okFonts, fonts = pcall(lsm.HashTable, lsm, "font")
            if okFonts and type(fonts) == "table" then
                for name, path in pairs(fonts) do
                    Add(name, path)
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return result
end

function BFH:OpenFontPicker(anchor)
    -- Rebuild the popup every time. This avoids a broken/half-created popup
    -- getting stuck after a Lua error or being closed.
    if self.fontPicker then
        self.fontPicker:Hide()
        self.fontPicker:SetParent(nil)
        self.fontPicker = nil
    end

    local p = CreateFrame("Frame", "BlightfallFontPicker", UIParent, "BackdropTemplate")
    p:SetSize(430, 520)
    p:SetFrameStrata("FULLSCREEN_DIALOG")
    p:SetClampedToScreen(true)
    p:EnableMouse(true)
    p:SetMovable(true)
    Backdrop(p, {0.025,0.027,0.034,0.995})
    self.fontPicker = p

    local title = FS(p, "Choose Font", 17, WHITE)
    title:SetPoint("TOPLEFT", 18, -16)

    local close = AccentCloseButton(p, function()
        p:Hide()
    end, 36)
    close:SetPoint("TOPRIGHT", -12, -12)

    local search = CreateFrame("EditBox", nil, p, "BackdropTemplate")
    search:SetSize(380, 30)
    search:SetPoint("TOPLEFT", 18, -54)
    Backdrop(search, {0.04,0.043,0.052,1})
    search:SetFont(self.db.font or "Fonts\\FRIZQT__.TTF", 12, "")
    table.insert(self.configEditBoxes, search)
    search:SetTextInsets(10,8,0,0)
    search:SetAutoFocus(false)

    local placeholder = FS(search, "Search fonts...", 11, MUTED)
    placeholder:SetPoint("LEFT", 10, 0)

    local scroll = CreateFrame("ScrollFrame", nil, p, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -96)
    scroll:SetPoint("BOTTOMRIGHT", -42, 18)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(365)
    child:SetHeight(1)
    scroll:SetScrollChild(child)

    local rows = {}

    local function BuildRows()
        local q = (search:GetText() or ""):lower()
        placeholder:SetShown(q == "")

        local fonts = BFH:GetAvailableFonts()
        local matches = {}

        for _, font in ipairs(fonts) do
            if q == "" or font.name:lower():find(q, 1, true) then
                matches[#matches + 1] = font
            end
        end

        local y = -4
        for i, font in ipairs(matches) do
            local row = rows[i]
            if not row then
                row = CreateFrame("Button", nil, child, "BackdropTemplate")
                row:SetSize(350, 38)
                row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
                row:SetBackdropColor(0.05,0.053,0.064,0.95)

                row.text = row:CreateFontString(nil, "OVERLAY")
                row.text:SetPoint("LEFT", 10, 0)
                row.text:SetPoint("RIGHT", -10, 0)
                row.text:SetJustifyH("LEFT")
                row.text:SetTextColor(0.95,0.96,0.99)
                row.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "")

                row:SetScript("OnEnter", function(self)
                    self:SetBackdropColor(0.12,0.06,0.18,1)
                end)
                row:SetScript("OnLeave", function(self)
                    self:SetBackdropColor(0.05,0.053,0.064,0.95)
                end)

                rows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, y)
            row.fontData = font

            local ok = row.text:SetFont(font.path, 15, "")
            if not ok then
                row.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "")
            end

            row.text:SetText(font.name)

            row:SetScript("OnClick", function(self)
                BFH.db.font = self.fontData.path
                BFH.db.fontName = self.fontData.name
                BFH:ApplyDisplaySettings()
                BFH:ApplyConfigFont()
                p:Hide()
                BFH:RefreshConfig()
            end)

            row:Show()
            y = y - 42
        end

        for i = #matches + 1, #rows do
            rows[i]:Hide()
        end

        if #matches == 0 then
            local noFonts = rows[1]
            if not noFonts then
                noFonts = CreateFrame("Button", nil, child)
                noFonts:SetSize(350, 38)
                noFonts.text = noFonts:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                noFonts.text:SetPoint("LEFT", 10, 0)
                noFonts.text:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
                rows[1] = noFonts
            end
            noFonts:ClearAllPoints()
            noFonts:SetPoint("TOPLEFT", 0, -4)
            noFonts.text:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
            noFonts.text:SetText("No matching fonts.")
            noFonts:Show()
            child:SetHeight(50)
        else
            child:SetHeight(math.max(50, -y + 8))
        end
    end

    search:SetScript("OnTextChanged", BuildRows)

    p:ClearAllPoints()
    p:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    p:Show()
    BuildRows()
end


function BFH:ApplyConfigFont()
    local path = self.db.font or "Fonts\\FRIZQT__.TTF"
    for _, item in ipairs(self.configFontStrings or {}) do
        if item.obj then
            local ok = item.obj:SetFont(path, item.size or 12, "")
            if not ok then item.obj:SetFont("Fonts\\FRIZQT__.TTF", item.size or 12, "") end
        end
    end
    for _, edit in ipairs(self.configEditBoxes or {}) do
        if edit and edit.SetFont then
            local ok = edit:SetFont(path, 12, "")
            if not ok then edit:SetFont("Fonts\\FRIZQT__.TTF", 12, "") end
        end
    end
end

function BFH:ApplyConfigTheme()
    SyncTheme()
    if not self.config then return end
    local b = self.db.menuBackgroundColor or BG
    self.config:SetBackdropColor(b[1], b[2], b[3], b[4] or 1)

    if self.configHeader then
        self.configHeader:SetBackdropColor(
            math.max(0, b[1] * 0.72),
            math.max(0, b[2] * 0.72),
            math.max(0, b[3] * 0.72),
            1
        )
    end

    if self.configNav then
        local p = self.db.menuPanelColor or PANEL
        self.configNav:SetBackdropColor(p[1], p[2], p[3], p[4] or 1)
    end

    for name, button in pairs(self.navButtons or {}) do
        if name == self.currentPage then
            local a = self.db.menuAccentColor or {0.62,0.11,1,1}
            button:SetBackdropColor(a[1]*0.18, a[2]*0.18, a[3]*0.18, 1)
            button:SetBackdropBorderColor(a[1], a[2], a[3], 1)
        end
    end
end

local function Hex(color)
    local r = math.floor((color[1] or 0) * 255 + 0.5)
    local g = math.floor((color[2] or 0) * 255 + 0.5)
    local b = math.floor((color[3] or 0) * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function ColorButton(parent, label, getter, setter, alphaEnabled)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(300, 44)

    local text = FS(wrap, label, 11, {0.73,0.76,0.82})
    text:SetPoint("LEFT", 0, 0)

    local swatch = CreateFrame("Button", nil, wrap, "BackdropTemplate")
    swatch:SetSize(92, 28)
    swatch:SetPoint("RIGHT", 0, 0)
    swatch:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    swatch:SetBackdropBorderColor(0.25,0.26,0.30,1)

    local hex = FS(swatch, "", 10, {1,1,1})
    hex:SetPoint("CENTER")

    function wrap:Refresh()
        local c = getter()
        swatch:SetBackdropColor(c[1], c[2], c[3], c[4] or 1)
        hex:SetText(Hex(c))
    end

    swatch:SetScript("OnClick", function()
        local old = BFH.DeepCopy(getter())
        local c = getter()
        local info = {
            r = c[1], g = c[2], b = c[3],
            hasOpacity = alphaEnabled and true or false,
            opacity = 1 - (c[4] or 1),
            swatchFunc = function()
                local r,g,b = ColorPickerFrame:GetColorRGB()
                local a = c[4] or 1
                if alphaEnabled and ColorPickerFrame.GetColorAlpha then
                    a = ColorPickerFrame:GetColorAlpha()
                end
                setter({r,g,b,a})
                wrap:Refresh()
                BFH:ApplyDisplaySettings()
                BFH:ApplyConfigTheme()
            end,
            opacityFunc = function()
                local r,g,b = ColorPickerFrame:GetColorRGB()
                local a = ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha() or (c[4] or 1)
                setter({r,g,b,a})
                wrap:Refresh()
                BFH:ApplyDisplaySettings()
                BFH:ApplyConfigTheme()
            end,
            cancelFunc = function()
                setter(old)
                wrap:Refresh()
                BFH:ApplyDisplaySettings()
                BFH:ApplyConfigTheme()
            end,
        }
        if ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            ColorPickerFrame.func = info.swatchFunc
            ColorPickerFrame.opacityFunc = info.opacityFunc
            ColorPickerFrame.cancelFunc = info.cancelFunc
            ColorPickerFrame.hasOpacity = info.hasOpacity
            ColorPickerFrame.opacity = info.opacity
            ColorPickerFrame:SetColorRGB(info.r, info.g, info.b)
            ColorPickerFrame:Show()
        end
    end)

    return wrap
end


function BFH:GetAvailableBarTextures()
    local result, seen = {}, {}

    local function Add(name, path)
        if type(name) ~= "string" or type(path) ~= "string" or seen[path] then return end
        seen[path] = true
        result[#result + 1] = {name=name, path=path}
    end

    Add("Blizzard", "Interface\\TargetingFrame\\UI-StatusBar")
    Add("Blizzard Raid", "Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    Add("Solid", "Interface\\Buttons\\WHITE8X8")

    local libStub = _G.LibStub
    if libStub and type(libStub.GetLibrary) == "function" then
        local ok, lsm = pcall(libStub.GetLibrary, libStub, "LibSharedMedia-3.0", true)
        if ok and lsm and type(lsm.HashTable) == "function" then
            local okBars, bars = pcall(lsm.HashTable, lsm, "statusbar")
            if okBars and type(bars) == "table" then
                for name, path in pairs(bars) do Add(name, path) end
            end
        end
    end

    table.sort(result, function(a,b) return a.name:lower() < b.name:lower() end)
    return result
end

function BFH:OpenBarTexturePicker(anchor)
    if self.barTexturePicker then
        self.barTexturePicker:Hide()
        self.barTexturePicker:SetParent(nil)
        self.barTexturePicker = nil
    end

    local p = CreateFrame("Frame", "BlightfallBarTexturePicker", UIParent, "BackdropTemplate")
    p:SetSize(430, 500)
    p:SetFrameStrata("FULLSCREEN_DIALOG")
    p:SetClampedToScreen(true)
    p:EnableMouse(true)
    Backdrop(p, {0.025,0.027,0.034,0.995})
    self.barTexturePicker = p

    local title = FS(p, "Choose Bar Style", 17, WHITE)
    title:SetPoint("TOPLEFT", 18, -16)

    local close = AccentCloseButton(p, function()
        p:Hide()
    end, 36)
    close:SetPoint("TOPRIGHT", -12, -12)

    local search = CreateFrame("EditBox", nil, p, "BackdropTemplate")
    search:SetSize(380, 30)
    search:SetPoint("TOPLEFT", 18, -54)
    Backdrop(search, {0.04,0.043,0.052,1})
    search:SetFont(BFH.db.font or "Fonts\\FRIZQT__.TTF", 12, "")
    search:SetTextInsets(10,8,0,0)
    search:SetAutoFocus(false)

    local placeholder = FS(search, "Search bar styles...", 11, MUTED)
    placeholder:SetPoint("LEFT", 10, 0)

    local scroll = CreateFrame("ScrollFrame", nil, p, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -96)
    scroll:SetPoint("BOTTOMRIGHT", -42, 18)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(365)
    child:SetHeight(1)
    scroll:SetScrollChild(child)

    local rows = {}

    local function BuildRows()
        local q = (search:GetText() or ""):lower()
        placeholder:SetShown(q == "")
        local textures = BFH:GetAvailableBarTextures()
        local matches = {}

        for _, tex in ipairs(textures) do
            if q == "" or tex.name:lower():find(q, 1, true) then
                matches[#matches+1] = tex
            end
        end

        local y = -4
        for i, tex in ipairs(matches) do
            local row = rows[i]
            if not row then
                row = CreateFrame("Button", nil, child, "BackdropTemplate")
                row:SetSize(350, 46)
                row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
                row:SetBackdropColor(0.05,0.053,0.064,0.95)

                row.preview = row:CreateTexture(nil, "ARTWORK")
                row.preview:SetPoint("LEFT", 10, 0)
                row.preview:SetSize(120, 16)

                row.text = row:CreateFontString(nil, "OVERLAY")
                row.text:SetPoint("LEFT", row.preview, "RIGHT", 12, 0)
                row.text:SetFont(BFH.db.font or "Fonts\\FRIZQT__.TTF", 13, "")
                row.text:SetTextColor(0.95,0.96,0.99)

                row:SetScript("OnEnter", function(self)
                    self:SetBackdropColor(0.12,0.06,0.18,1)
                end)
                row:SetScript("OnLeave", function(self)
                    self:SetBackdropColor(0.05,0.053,0.064,0.95)
                end)

                rows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, y)
            row.textureData = tex
            row.preview:SetTexture(tex.path)
            row.preview:SetVertexColor(0.62,0.11,1,1)
            row.text:SetText(tex.name)

            row:SetScript("OnClick", function(self)
                BFH.db.barTexture = self.textureData.path
                BFH.db.barTextureName = self.textureData.name
                BFH:ApplyDisplaySettings()
                p:Hide()
                BFH:RefreshConfig()
            end)

            row:Show()
            y = y - 50
        end

        for i = #matches+1, #rows do rows[i]:Hide() end
        child:SetHeight(math.max(50, -y + 8))
    end

    search:SetScript("OnTextChanged", BuildRows)
    p:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    p:Show()
    BuildRows()
end

function BFH:InitializeConfig()
    SyncTheme()
    self.configFontStrings = {}
    self.configEditBoxes = {}

    local f = CreateFrame("Frame", "BlightfallConfig", UIParent, "BackdropTemplate")
    f:SetSize(self.db.configWidth, self.db.configHeight)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:SetResizeBounds(900, 600, 1300, 900)
    f:EnableMouse(true)
    Backdrop(f, BG)
    f:Hide()
    self.config = f

    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    self.configHeader = header
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(78)
    header:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    header:SetBackdropColor(0.035,0.038,0.048,1)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() f:StartMoving() end)
    header:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local title = FS(header, "Blightfall", 24, WHITE)
    title:SetPoint("LEFT", 26, 10)

    local ver = FS(header, "v"..self.VERSION, 11, MUTED)
    ver:SetPoint("LEFT", title, "RIGHT", 10, -2)

    local author = FS(header, "by JSAL", 11, {0.78, 0.38, 1})
    author:SetPoint("LEFT", ver, "RIGHT", 10, 0)

    local sub = FS(header, "Unholy DK cast timing assistant", 11, MUTED)
    sub:SetPoint("TOPLEFT", 28, -52)

    local close = AccentCloseButton(header, function()
        if BFH.fontPicker then BFH.fontPicker:Hide() end
        if BFH.barTexturePicker then BFH.barTexturePicker:Hide() end
        f:Hide()
        BFH:StopStage()
    end, 46)
    close:SetPoint("TOPRIGHT", -14, -16)
    self.closeButton = close

    local search = CreateFrame("EditBox", nil, header, "BackdropTemplate")
    search:SetSize(250, 30)
    search:SetPoint("RIGHT", close, "LEFT", -18, 0)
    Backdrop(search, {0.025,0.028,0.035,1})
    search:SetAutoFocus(false)
    search:SetFont(self.db.font or "Fonts\\FRIZQT__.TTF", 12, "")
    table.insert(self.configEditBoxes, search)
    search:SetTextInsets(10,8,0,0)
    local placeholder = FS(search, "Search settings...", 11, MUTED)
    placeholder:SetPoint("LEFT", 10, 0)
    search:SetScript("OnTextChanged", function(self)
        placeholder:SetShown(self:GetText() == "")
        BFH.searchText = (self:GetText() or ""):lower()
        BFH:RefreshSearch()
    end)

    local nav = CreateFrame("Frame", nil, f, "BackdropTemplate")
    self.configNav = nav
    nav:SetPoint("TOPLEFT", 0, -78)
    nav:SetPoint("BOTTOMLEFT")
    nav:SetWidth(205)
    nav:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    nav:SetBackdropColor(0.02,0.022,0.028,0.98)

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", -20, 20)
    self.content = content

    local resize = CreateFrame("Button", nil, f, "BackdropTemplate")
    resize:SetSize(28,28)
    resize:SetPoint("BOTTOMRIGHT", -10, 10)
    resize:SetFrameLevel(f:GetFrameLevel() + 30)
    resize:EnableMouse(true)
    resize:SetBackdrop({
        bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        edgeSize=1
    })
    resize:SetBackdropColor(0.045,0.048,0.058,0.95)
    resize:SetBackdropBorderColor(0.22,0.23,0.27,1)
    local rt = FS(resize, "◢", 18, {0.7,0.72,0.78})
    rt:SetPoint("CENTER", 0, -1)
    AddTooltip(resize, "Resize window", "Drag this corner to change the Blightfall settings window size.")
    resize:SetScript("OnMouseDown", function()
        f:StartSizing("BOTTOMRIGHT")
    end)
    resize:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        BFH.db.configWidth = math.floor(f:GetWidth() + 0.5)
        BFH.db.configHeight = math.floor(f:GetHeight() + 0.5)
    end)

    self.pages = {}
    self.navButtons = {}
    self.currentPage = "General"

    local pageNames = {"General","Display","Timing","Sound","Fonts","Colors","Profiles"}

    for i, name in ipairs(pageNames) do
        local b = Button(nav, name, 177, 38, function() BFH:ShowPage(name) end)
        b:SetPoint("TOPLEFT", 14, -20 - (i-1)*46)
        self.navButtons[name] = b

        local holder = CreateFrame("Frame", nil, content)
        holder:SetAllPoints()
        holder:Hide()

        local page = MakeScrollablePage(holder)
        self.pages[name] = {holder=holder, page=page}
    end

    local searchHolder = CreateFrame("Frame", nil, content)
    searchHolder:SetAllPoints()
    searchHolder:Hide()
    self.searchHolder = searchHolder

    local searchPage = MakeScrollablePage(searchHolder)
    self.searchPage = searchPage
    PageTitle(searchPage, "Search Results", "Click a result to open the relevant settings tab.")
    self.searchRows = {}

    local function Page(name)
        return self.pages[name].page
    end

    -- General
    do
        local p = Page("General")
        PageTitle(p, "General", "Core behaviour, minimap access and display positioning.")

        local c1 = Checkbox(p, "Enable Blightfall",
            function() return self.db.enabled end,
            function(v) self.db.enabled = v; if not v then self:StopStage() end end)
        c1:SetPoint("TOPLEFT", 30, -105)
        HelpBeside(p, c1, "Enable addon", "Turns the helper on or off without disabling the addon in WoW's addon list.")

        local c2 = Checkbox(p, "Lock display position",
            function() return self.db.locked end,
            function(v) self.db.locked = v; self:ApplyDisplaySettings() end)
        c2:SetPoint("TOPLEFT", 30, -155)
        HelpBeside(p, c2, "Lock position", "Unlock this to drag the active timer/preview anywhere on your screen.")

        local c3 = Checkbox(p, "Show minimap button",
            function() return self.db.showMinimapButton end,
            function(v) self.db.showMinimapButton = v; self:UpdateMinimapButton() end)
        c3:SetPoint("TOPLEFT", 30, -205)
        HelpBeside(p, c3, "Minimap button", "Shows the Blightfall icon on the minimap. Left-click it to open /bf and drag it around the minimap edge.")


        local minimapHover = Checkbox(p, "Show minimap button only on mouseover",
            function() return self.db.minimapMouseoverOnly end,
            function(v)
                self.db.minimapMouseoverOnly = v
                self:UpdateMinimapButton()
            end,
            "Minimap mouseover", "When enabled, the minimap icon is invisible until your mouse moves over its saved position.")
        minimapHover:SetPoint("TOPLEFT", 30, -255)
        HelpBeside(p, minimapHover, "Minimap mouseover",
            "When enabled, the minimap icon is invisible until your mouse moves over its saved position.")

        local soulModule = Checkbox(p, "Enable Soul Reaper timer",
            function() return self.db.enableSoulReaperBar end,
            function(v)
                self.db.enableSoulReaperBar = v
                if not v and self.stage == "SOUL" then self:StopStage() end
            end)
        soulModule:SetPoint("TOPLEFT", 30, -315)
        HelpBeside(p, soulModule, "Soul Reaper timer",
            "Shows or hides the Soul Reaper timer module. The sequence still tracks Soul Reaper casts so Blightfall can work independently.")

        local blightModule = Checkbox(p, "Enable Blightfall timer",
            function() return self.db.enableBlightfallBar end,
            function(v)
                self.db.enableBlightfallBar = v
                if not v and self.stage == "BLIGHT" then self:StopStage() end
            end)
        blightModule:SetPoint("TOPLEFT", 370, -315)
        HelpBeside(p, blightModule, "Blightfall timer",
            "Shows or hides the Blightfall timer module independently of Soul Reaper.")

        local dungeonDisable = Checkbox(p, "Disable helper in dungeons",
            function() return self.db.disableInDungeons end,
            function(v)
                self.db.disableInDungeons = v
                self:RefreshInstanceState()
            end)
        dungeonDisable:SetPoint("TOPLEFT", 30, -365)
        HelpBeside(p, dungeonDisable, "Disable in dungeons",
            "When enabled, combat timers are disabled inside 5-player dungeon instances. Off by default.")

        local talentStatus = FS(p, "", 11, MUTED)
        talentStatus:SetPoint("TOPLEFT", 30, -420)
        self.talentStatusText = talentStatus

        local test = Button(p, "Preview Soul Reaper", 155, 30, function()
            if self:HasSoulReaper() then self:ShowPreview("SOUL") end
        end)
        test:SetPoint("TOPLEFT", 30, -465)

        local test2 = Button(p, "Preview Blightfall", 155, 30, function()
            if self:HasBlightfall() then self:ShowPreview("BLIGHT") end
        end)
        test2:SetPoint("LEFT", test, "RIGHT", 12, 0)

        local stop = Button(p, "Stop Preview", 125, 30, function() self:StopStage() end)
        local previewNote = FS(p, "Preview loops continuously until you press Stop Preview.", 11, MUTED)
        previewNote:SetPoint("TOPLEFT", 30, -505)

        stop:SetPoint("LEFT", test2, "RIGHT", 12, 0)

        local credit = FS(p, "Created by JSAL", 11, MUTED)
        credit:SetPoint("TOPLEFT", 30, -610)

        local reset = Button(p, "Reset Position", 145, 30, function()
            self.db.point = "CENTER"
            self.db.relativePoint = "CENTER"
            self.db.x = 0
            self.db.y = 0
            self:ApplyPosition()
        end)
        reset:SetPoint("TOPLEFT", 30, -550)

        self.pages.General.controls = {c1,c2,c3,minimapHover,soulModule,blightModule,dungeonDisable}
    end

    -- Display
    do
        local p = Page("Display")
        PageTitle(p, "Display", "Control layout, bar style, text, icons, marker and borders.")

        local leftX, rightX = 30, 370

        -- GENERAL DISPLAY
        local mode = Dropdown(
            p, "Display mode",
            {{text="Progress Bar",value="BAR"},{text="Icon Only",value="ICON"},{text="Text Only",value="TEXT"}},
            function() return self.db.displayMode end,
            function(v) self.db.displayMode = v end
        )
        mode:SetPoint("TOPLEFT", leftX, -105)
        HelpBeside(p, mode, "Display mode",
            "Progress Bar shows a bar. Icon Only shows the spell icon. Text Only removes both the bar and icon.")

        local scale = Slider(p, "Overall scale", 0.5, 2.0, 0.05,
            function() return self.db.scale end,
            function(v) self.db.scale = v end,
            function(v) return string.format("%.2f",v) end)
        scale:SetPoint("TOPLEFT", leftX, -185)

        -- BAR SIZE / BACKGROUND
        local barWidth = Slider(p, "Bar width", 100, 500, 5,
            function() return self.db.barWidth end,
            function(v) self.db.barWidth = v end,
            function(v) return string.format("%d px",v) end)
        barWidth:SetPoint("TOPLEFT", rightX, -185)

        local barHeight = Slider(p, "Bar height", 10, 60, 1,
            function() return self.db.barHeight end,
            function(v) self.db.barHeight = v end,
            function(v) return string.format("%d px",v) end)
        barHeight:SetPoint("TOPLEFT", leftX, -265)

        local bg = Slider(p, "Bar background opacity", 0, 1, 0.05,
            function() return self.db.backgroundAlpha end,
            function(v) self.db.backgroundAlpha = v end,
            function(v) return string.format("%d%%",v*100) end)
        bg:SetPoint("TOPLEFT", rightX, -265)

        -- BAR STYLE
        local barStyleLabel = FS(p, "Bar style", 11, {0.73,0.76,0.82})
        barStyleLabel:SetPoint("TOPLEFT", leftX, -350)

        local barStyle = Button(p, self.db.barTextureName or "Blizzard", 300, 30, function(selfButton)
            BFH:OpenBarTexturePicker(selfButton)
        end)
        barStyle:SetPoint("TOPLEFT", leftX, -372)
        self.barStyleButton = barStyle
        HelpBeside(p, barStyle, "Bar style",
            "Choose the StatusBar texture. LibSharedMedia textures from Quartz, WeakAuras, SharedMedia and other addons appear automatically.")

        local reverse = Checkbox(p, "Reverse bar direction",
            function() return self.db.barReverseFill end,
            function(v) self.db.barReverseFill = v; self:ApplyDisplaySettings() end)
        reverse:SetPoint("TOPLEFT", rightX, -372)

        local smooth = Checkbox(p, "Smooth bar movement",
            function() return self.db.barSmooth end,
            function(v) self.db.barSmooth = v end)
        smooth:SetPoint("TOPLEFT", rightX, -414)

        -- BAR TEXT
        local showBarText = Checkbox(p, "Show text on progress bar",
            function() return self.db.showBarText end,
            function(v) self.db.showBarText = v; self:ApplyDisplaySettings() end)
        showBarText:SetPoint("TOPLEFT", leftX, -470)
        HelpBeside(p, showBarText, "Bar text",
            "Turn this off for a clean progress bar with no spell name or countdown text.")

        local textPos = Dropdown(
            p, "Bar text position",
            {{text="Left",value="LEFT"},{text="Center",value="CENTER"},{text="Right",value="RIGHT"}},
            function() return self.db.barTextPosition end,
            function(v) self.db.barTextPosition = v end
        )
        textPos:SetPoint("TOPLEFT", rightX, -460)
        HelpBeside(p, textPos, "Bar text position",
            "Moves the spell name to the left, centre or right. Right swaps the countdown to the left. Centre shows only the spell name to prevent overlap.")

        local spark = Checkbox(p, "Show moving marker",
            function() return self.db.showSpark end,
            function(v) self.db.showSpark = v; self:ApplyDisplaySettings() end)
        spark:SetPoint("TOPLEFT", leftX, -530)

        -- BAR ICON
        local showIcon = Checkbox(p, "Show spell icon on bar",
            function() return self.db.showIcon end,
            function(v) self.db.showIcon = v; self:ApplyDisplaySettings() end)
        showIcon:SetPoint("TOPLEFT", rightX, -530)

        local iconPos = Dropdown(
            p, "Bar icon position",
            {{text="Left",value="LEFT"},{text="Right",value="RIGHT"}},
            function() return self.db.iconPosition end,
            function(v) self.db.iconPosition = v end
        )
        iconPos:SetPoint("TOPLEFT", leftX, -595)

        local iconSize = Slider(p, "Bar icon size", 10, 80, 1,
            function() return self.db.iconSize end,
            function(v) self.db.iconSize = v end,
            function(v) return string.format("%d px",v) end)
        iconSize:SetPoint("TOPLEFT", rightX, -595)

        -- ICON ONLY
        local iconOnlySize = Slider(p, "Icon-only size", 32, 128, 2,
            function() return self.db.iconOnlySize end,
            function(v) self.db.iconOnlySize = v end,
            function(v) return string.format("%d px",v) end)
        iconOnlySize:SetPoint("TOPLEFT", leftX, -680)

        local iconCountdownPos = Dropdown(
            p, "Icon countdown position",
            {{text="Below Icon",value="BELOW"},{text="Center of Icon",value="CENTER"}},
            function() return self.db.iconCountdownPosition end,
            function(v) self.db.iconCountdownPosition = v end
        )
        iconCountdownPos:SetPoint("TOPLEFT", rightX, -670)
        HelpBeside(p, iconCountdownPos, "Icon countdown position",
            "Choose whether the remaining time sits below the icon or directly in its centre.")

        local iconCountdownSize = Slider(p, "Icon countdown text size", 8, 48, 1,
            function() return self.db.iconCountdownFontSize end,
            function(v) self.db.iconCountdownFontSize = v end,
            function(v) return string.format("%d px",v) end)
        iconCountdownSize:SetPoint("TOPLEFT", leftX, -760)

        local iconCountdownColor = ColorButton(p, "Icon countdown colour",
            function() return self.db.iconCountdownColor end,
            function(v) self.db.iconCountdownColor = v end, true)
        iconCountdownColor:SetPoint("TOPLEFT", rightX, -760)

        -- BORDERS
        local barBorderToggle = Checkbox(p, "Show bar border",
            function() return self.db.barBorderEnabled end,
            function(v) self.db.barBorderEnabled = v; self:ApplyDisplaySettings() end)
        barBorderToggle:SetPoint("TOPLEFT", leftX, -845)

        local iconBorderToggle = Checkbox(p, "Show icon border",
            function() return self.db.iconBorderEnabled end,
            function(v) self.db.iconBorderEnabled = v; self:ApplyDisplaySettings() end)
        iconBorderToggle:SetPoint("TOPLEFT", rightX, -845)

        local barBorderSize = Slider(p, "Bar border thickness", 0, 8, 1,
            function() return self.db.barBorderSize end,
            function(v) self.db.barBorderSize = v end,
            function(v) return string.format("%d px", v) end)
        barBorderSize:SetPoint("TOPLEFT", leftX, -905)

        local iconBorderSize = Slider(p, "Icon border thickness", 0, 8, 1,
            function() return self.db.iconBorderSize end,
            function(v) self.db.iconBorderSize = v end,
            function(v) return string.format("%d px", v) end)
        iconBorderSize:SetPoint("TOPLEFT", rightX, -905)

        local barBorderColor = ColorButton(p, "Bar border colour",
            function() return self.db.barBorderColor end,
            function(v) self.db.barBorderColor = v end, true)
        barBorderColor:SetPoint("TOPLEFT", leftX, -980)

        local iconBorderColor = ColorButton(p, "Icon border colour",
            function() return self.db.iconBorderColor end,
            function(v) self.db.iconBorderColor = v end, true)
        iconBorderColor:SetPoint("TOPLEFT", rightX, -980)

        self.pages.Display.controls = {
            mode,scale,barWidth,barHeight,bg,barStyle,reverse,smooth,
            showBarText,textPos,spark,showIcon,iconPos,iconSize,
            iconOnlySize,iconCountdownPos,iconCountdownSize,iconCountdownColor,
            barBorderToggle,iconBorderToggle,barBorderSize,iconBorderSize,
            barBorderColor,iconBorderColor
        }
    end

    -- Timing
    do
        local p = Page("Timing")
        PageTitle(p, "Timing", "Adjust the recommended time between each cast.")

        local s1 = Slider(p, "Soul Reaper delay after Dark Transformation", 1, 12, 0.1,
            function() return self.db.soulDelay end,
            function(v) self.db.soulDelay = v end,
            function(v) return string.format("%.1fs",v) end)
        s1:SetPoint("TOPLEFT", 30, -120)
        HelpBeside(p, s1, "Soul Reaper delay", "How long the Soul Reaper timer runs after Dark Transformation. Casting Soul Reaper early immediately moves on to Blightfall.")

        local s2 = Slider(p, "Blightfall delay after Soul Reaper", 1, 12, 0.1,
            function() return self.db.blightDelay end,
            function(v) self.db.blightDelay = v end,
            function(v) return string.format("%.1fs",v) end)
        s2:SetPoint("TOPLEFT", 30, -215)
        HelpBeside(p, s2, "Blightfall delay", "How long the Blightfall timer runs after the first Soul Reaper following Dark Transformation.")

        local s3 = Slider(p, "Spoken countdown starts at", 1, 10, 1,
            function() return self.db.countdownStart end,
            function(v) self.db.countdownStart = v end,
            function(v) return tostring(v) end)
        s3:SetPoint("TOPLEFT", 30, -310)
        HelpBeside(p, s3, "Countdown start", "Choose how many of the final seconds are spoken. The included custom number pack supports 1 through 10.")

        local cancelAfterDT = Checkbox(p, "Cancel sequence when Dark Transformation ends",
            function() return self.db.cancelAfterDT end,
            function(v)
                self.db.cancelAfterDT = v
                if v then
                    self:StartDarkTransformationWatcher()
                    self:CheckDarkTransformationAura()
                else
                    self:CancelDarkTransformationWatcher()
                    self.dtGracePending = false
                end
            end)
        cancelAfterDT:SetPoint("TOPLEFT", 30, -395)
        HelpBeside(p, cancelAfterDT, "Cancel after Dark Transformation",
            "Stops the current Soul Reaper/Blightfall sequence after Dark Transformation disappears from your ghoul. Once cancelled, a new sequence requires another Dark Transformation cast.")

        local dtGrace = Slider(p, "Grace period after Dark Transformation ends", 0, 10, 1,
            function() return self.db.dtCancelGrace or 5 end,
            function(v) self.db.dtCancelGrace = v end,
            function(v)
                if v == 1 then return "1 second" end
                return string.format("%d seconds", v)
            end)
        dtGrace:SetPoint("TOPLEFT", 30, -475)
        HelpBeside(p, dtGrace, "Grace period",
            "Choose how long the sequence stays valid after Dark Transformation ends. 0 seconds cancels immediately; the default is 5 seconds.")

        local precision = Dropdown(
            p, "Timer precision",
            {{text="Whole seconds",value=0},{text="1 decimal",value=1},{text="2 decimals",value=2}},
            function() return self.db.precision end,
            function(v) self.db.precision = v end
        )
        precision:SetPoint("TOPLEFT", 30, -575)

        self.pages.Timing.controls = {s1,s2,s3,cancelAfterDT,dtGrace,precision}
    end

    -- Sound
    do
        local p = Page("Sound")
        PageTitle(p, "Sound", "Choose your uploaded number files or WoW's built-in text-to-speech.")

        local enabled = Checkbox(p, "Enable spoken countdown",
            function() return self.db.soundEnabled end,
            function(v) self.db.soundEnabled = v; if not v then self:StopTTS() end end)
        enabled:SetPoint("TOPLEFT", 30, -105)

        local mode = Dropdown(
            p, "Countdown audio mode",
            {{text="Custom 1-10 voice files",value="FILES"},{text="WoW Text-to-Speech",value="TTS"}},
            function() return self.db.audioMode end,
            function(v) self.db.audioMode = v; if v ~= "TTS" then self:StopTTS() end end
        )
        mode:SetPoint("TOPLEFT", 30, -170)
        HelpBeside(p, mode, "Audio mode", "Custom files use the 1-10 .ogg files bundled with Blightfall. TTS uses WoW's text-to-speech engine and has its own volume control.")

        local channel = Dropdown(
            p, "Custom-file WoW sound channel",
            {
                {text="Master",value="Master"},
                {text="SFX",value="SFX"},
                {text="Dialog",value="Dialog"},
                {text="Music",value="Music"},
                {text="Ambience",value="Ambience"},
            },
            function() return self.db.soundChannel end,
            function(v) self.db.soundChannel = v end
        )
        channel:SetPoint("TOPLEFT", 30, -250)
        HelpBeside(p, channel, "Sound channel", "Only applies to Custom Voice Files. These files follow the selected WoW mixer channel's volume.")

        local volume = Slider(p, "TTS volume", 0, 100, 1,
            function() return self.db.ttsVolume end,
            function(v) self.db.ttsVolume = v end,
            function(v) return string.format("%d%%",v) end)
        volume:SetPoint("TOPLEFT", 370, -250)
        HelpBeside(p, volume, "TTS volume", "Independent volume passed to WoW's text-to-speech system. It does not alter your normal SFX/Music/Ambience sliders.")

        local rate = Slider(p, "TTS voice speed", -10, 10, 1,
            function() return self.db.ttsRate end,
            function(v) self.db.ttsRate = v end,
            function(v) return tostring(v) end)
        rate:SetPoint("TOPLEFT", 370, -335)

        local voiceButton = Button(p, "Choose TTS Voice", 180, 30, function(selfButton)
            local voices = BFH:GetTTSVoices()
            if #voices == 0 then
                print("|cff9f1cffBlightfall:|r No WoW TTS voices are currently available.")
                return
            end
            MenuUtil.CreateContextMenu(selfButton, function(owner, rootDescription)
                for _, voice in ipairs(voices) do
                    local label = voice.name or ("Voice "..tostring(voice.voiceID))
                    rootDescription:CreateRadio(
                        label,
                        function() return BFH.db.ttsVoiceID == voice.voiceID end,
                        function()
                            BFH.db.ttsVoiceID = voice.voiceID
                            BFH:RefreshConfig()
                        end
                    )
                end
            end)
        end)
        voiceButton:SetPoint("TOPLEFT", 30, -340)

        local testTTS = Button(p, "Test TTS", 100, 30, function()
            local old = self.db.audioMode
            self.db.audioMode = "TTS"
            self:PlayCountdown(4)
            self.db.audioMode = old
        end)
        testTTS:SetPoint("LEFT", voiceButton, "RIGHT", 12, 0)

        local note = FS(p, "Test bundled custom sounds:", 11, MUTED)
        note:SetPoint("TOPLEFT", 30, -430)

        local x, y = 30, -460
        for n = 10, 1, -1 do
            local b = Button(p, tostring(n), 48, 30, function()
                local old = self.db.audioMode
                self.db.audioMode = "FILES"
                self:PlayCountdown(n)
                self.db.audioMode = old
            end)
            b:SetPoint("TOPLEFT", x, y)
            x = x + 56
            if n == 6 then x, y = 30, y - 42 end
        end

        self.pages.Sound.controls = {enabled,mode,channel,volume,rate}
    end

    -- Fonts
    do
        local p = Page("Fonts")
        PageTitle(p, "Fonts", "Choose the typeface and text sizes used by both the timer and the Blightfall menu.")

        local fontLabel = FS(p, "Font", 11, {0.73,0.76,0.82})
        fontLabel:SetPoint("TOPLEFT", 30, -110)

        local fontButton = Button(p, self.db.fontName or "Friz Quadrata", 320, 32, function(selfButton)
            BFH:OpenFontPicker(selfButton)
        end)
        fontButton:SetPoint("TOPLEFT", 30, -132)
        self.fontButton = fontButton
        HelpBeside(p, fontButton, "Font library",
            "Includes WoW fonts, fonts exposed through LibSharedMedia by addons such as WeakAuras, and compatible files placed in Blightfall\\Fonts.")

        local s1 = Slider(p, "Spell-name font size", 8, 32, 1,
            function() return self.db.labelFontSize end,
            function(v) self.db.labelFontSize = v end,
            function(v) return string.format("%d px",v) end)
        s1:SetPoint("TOPLEFT", 30, -220)

        local s2 = Slider(p, "Timer font size", 8, 32, 1,
            function() return self.db.timerFontSize end,
            function(v) self.db.timerFontSize = v end,
            function(v) return string.format("%d px",v) end)
        s2:SetPoint("TOPLEFT", 370, -220)

        local note = FS(p,
            "The selected font is also applied to the Blightfall settings interface.",
            11, MUTED)
        note:SetPoint("TOPLEFT", 30, -305)

        self.pages.Fonts.controls = {s1,s2}
    end

    -- Colors
    do
        local p = Page("Colors")
        PageTitle(p, "Colors", "Customize the addon menu and every timer colour. Defaults match the current design.")

        local c1 = ColorButton(p, "Soul Reaper bar", function() return self.db.soulColor end,
            function(v) self.db.soulColor = v end, false)
        c1:SetPoint("TOPLEFT", 30, -110)
        HelpBeside(p, c1, "Soul Reaper colour", "Default #1C28FF. Used from 4.0 seconds upward.")

        local c2 = ColorButton(p, "Blightfall bar", function() return self.db.blightColor end,
            function(v) self.db.blightColor = v end, false)
        c2:SetPoint("TOPLEFT", 370, -110)
        HelpBeside(p, c2, "Blightfall colour", "Default #9F1CFF. Used from 4.0 seconds upward.")

        local c3 = ColorButton(p, "Under 4 seconds", function() return self.db.dangerColor end,
            function(v) self.db.dangerColor = v end, false)
        c3:SetPoint("TOPLEFT", 30, -180)
        HelpBeside(p, c3, "Danger colour", "Default #FF0010. Both timers switch to this colour below 4 seconds.")

        local c4 = ColorButton(p, "Bar background", function() return self.db.barBackgroundColor end,
            function(v) self.db.barBackgroundColor = v end, false)
        c4:SetPoint("TOPLEFT", 370, -180)
        HelpBeside(p, c4, "Bar background", "Controls the dark empty/background portion of the timer bar.")

        local c5 = ColorButton(p, "Menu background", function() return self.db.menuBackgroundColor end,
            function(v) self.db.menuBackgroundColor = v end, true)
        c5:SetPoint("TOPLEFT", 30, -275)

        local c6 = ColorButton(p, "Menu panel colour", function() return self.db.menuPanelColor end,
            function(v) self.db.menuPanelColor = v end, true)
        c6:SetPoint("TOPLEFT", 370, -275)

        local c7 = ColorButton(p, "Menu accent colour", function() return self.db.menuAccentColor end,
            function(v) self.db.menuAccentColor = v end, false)
        c7:SetPoint("TOPLEFT", 30, -345)
        HelpBeside(p, c7, "Accent colour", "Used for active tabs, sliders, checkboxes and highlights.")

        local reset = Button(p, "Reset Colours to Defaults", 190, 30, function()
            self.db.soulColor = {0x1C/255, 0x28/255, 0xFF/255, 1}
            self.db.blightColor = {0x9F/255, 0x1C/255, 0xFF/255, 1}
            self.db.dangerColor = {0xFF/255, 0x00/255, 0x10/255, 1}
            self.db.barBackgroundColor = {0.018, 0.018, 0.022, 1}
            self.db.menuBackgroundColor = {0.025, 0.027, 0.034, 0.985}
            self.db.menuPanelColor = {0.052, 0.055, 0.066, 0.98}
            self.db.menuAccentColor = {0.62, 0.11, 1.00, 1}
            self:ApplyDisplaySettings()
            self:ApplyConfigTheme()
            self:RefreshConfig()
        end)
        reset:SetPoint("TOPLEFT", 30, -430)

        self.pages.Colors.controls = {c1,c2,c3,c4,c5,c6,c7}
    end

    -- Profiles
    do
        local p = Page("Profiles")
        PageTitle(p, "Profiles", "Save and switch between complete Blightfall setups.")

        local current = FS(p, "Current profile: Default", 14, WHITE)
        current:SetPoint("TOPLEFT", 30, -115)
        self.currentProfileText = current

        local name = CreateFrame("EditBox", nil, p, "BackdropTemplate")
        name:SetSize(280, 30)
        name:SetPoint("TOPLEFT", 30, -165)
        Backdrop(name, {0.03,0.033,0.04,1})
        name:SetAutoFocus(false)
        name:SetFont(self.db.font or "Fonts\\FRIZQT__.TTF", 12, "")
        table.insert(self.configEditBoxes, name)
        name:SetTextInsets(10,8,0,0)
        self.profileNameBox = name

        local save = Button(p, "Save / Update", 130, 30, function()
            local n = (name:GetText() or ""):match("^%s*(.-)%s*$")
            if n == "" then n = self.db.activeProfile or "Default" end
            self.db.profiles[n] = self:CaptureProfile()
            self.db.activeProfile = n
            self:RefreshConfig()
        end)
        save:SetPoint("LEFT", name, "RIGHT", 12, 0)

        local load = Button(p, "Load", 90, 30, function()
            local n = (name:GetText() or ""):match("^%s*(.-)%s*$")
            if self.db.profiles[n] then
                self:ApplyProfile(self.db.profiles[n])
                self.db.activeProfile = n
                self:RefreshConfig()
            end
        end)
        load:SetPoint("LEFT", save, "RIGHT", 12, 0)

        local reset = Button(p, "Reset to Defaults", 155, 30, function()
            self:ResetToDefaults()
            self:RefreshConfig()
        end)
        reset:SetPoint("TOPLEFT", 30, -225)
    end

    self.searchIndex = {
        {name="Enable Blightfall", page="General", keywords="enable addon on off"},
        {name="Lock display position", page="General", keywords="lock unlock drag position"},
        {name="Show minimap button", page="General", keywords="minimap icon button"},
        {name="Display mode", page="Display", keywords="bar icon only display"},
        {name="Overall scale", page="Display", keywords="scale size"},
        {name="Bar width", page="Display", keywords="width bar"},
        {name="Bar style", page="Display", keywords="bar texture style quartz sharedmedia statusbar"},
        {name="Reverse bar", page="Display", keywords="bar reverse direction fill"},
        {name="Smooth bar", page="Display", keywords="bar smooth movement animation"},
        {name="Bar text", page="Display", keywords="bar text hide remove show name countdown"},
        {name="Bar text position", page="Display", keywords="bar text left center right position"},
        {name="Icon countdown position", page="Display", keywords="icon countdown center below position"},
        {name="Icon countdown text", page="Display", keywords="icon countdown text size colour color"},
        {name="Bar height", page="Display", keywords="height bar"},
        {name="Show spell icon", page="Display", keywords="icon bar spell"},
        {name="Icon position", page="Display", keywords="icon left right"},
        {name="Icon size", page="Display", keywords="icon size"},
        {name="Moving marker", page="Display", keywords="spark marker glow"},
        {name="Background opacity", page="Display", keywords="background opacity alpha"},
        {name="Soul Reaper delay", page="Timing", keywords="soul reaper dark transformation timer delay"},
        {name="Blightfall delay", page="Timing", keywords="blightfall soul reaper timer delay"},
        {name="Countdown start", page="Timing", keywords="countdown start seconds voice"},
        {name="Timer precision", page="Timing", keywords="precision decimals timer"},
        {name="Audio mode", page="Sound", keywords="tts custom voice files sound"},
        {name="Sound channel", page="Sound", keywords="master sfx dialog music ambience channel"},
        {name="TTS volume", page="Sound", keywords="tts volume voice"},
        {name="TTS speed", page="Sound", keywords="tts speed rate voice"},
        {name="TTS voice", page="Sound", keywords="tts voice selection"},
        {name="Font", page="Fonts", keywords="font typeface sharedmedia weakauras text"},
        {name="Font sizes", page="Fonts", keywords="font text size timer"},
        {name="Bar and icon borders", page="Display", keywords="border bar icon thickness colour color style"},
        {name="Bar border thickness", page="Display", keywords="bar border thickness size colour color"},
        {name="Icon border thickness", page="Display", keywords="icon border thickness size colour color"},
        {name="Soul Reaper colour", page="Colors", keywords="soul reaper blue hex color colour"},
        {name="Blightfall colour", page="Colors", keywords="blightfall purple hex color colour"},
        {name="Danger colour", page="Colors", keywords="red under 4 countdown color colour"},
        {name="Bar background colour", page="Colors", keywords="bar background color colour"},
        {name="Menu background colour", page="Colors", keywords="menu ui background color colour"},
        {name="Menu accent colour", page="Colors", keywords="accent slider checkbox tab color colour"},
        {name="Minimap mouseover", page="General", keywords="minimap mouseover hover hidden icon"},
        {name="Soul Reaper timer module", page="General", keywords="soul reaper timer module enable disable"},
        {name="Blightfall timer module", page="General", keywords="blightfall timer module enable disable"},
        {name="Disable in dungeons", page="General", keywords="dungeon instance party disable helper"},
        {name="Profiles", page="Profiles", keywords="profile preset save load"},
    }

    self:ShowPage("General")
end

function BFH:CaptureProfile()
    local omit = {
        profiles=true,
        activeProfile=true,
        configWidth=true,
        configHeight=true,
        minimapAngle=true,
    }
    local out = {}
    for k,v in pairs(self.db) do
        if not omit[k] then out[k] = self.DeepCopy(v) end
    end
    return out
end

function BFH:ApplyProfile(profile)
    for k,v in pairs(profile) do self.db[k] = self.DeepCopy(v) end
    self:ApplyDisplaySettings()
    self:UpdateMinimapButton()
end

function BFH:ResetToDefaults()
    local profiles = self.db.profiles
    local active = self.db.activeProfile
    local cw, ch = self.db.configWidth, self.db.configHeight
    local angle = self.db.minimapAngle

    for k in pairs(self.db) do self.db[k] = nil end
    self.CopyDefaults(self.defaults, self.db)

    self.db.profiles = profiles or {Default={}}
    self.db.activeProfile = active or "Default"
    self.db.configWidth, self.db.configHeight = cw or 1040, ch or 700
    self.db.minimapAngle = angle or 225

    self:ApplyDisplaySettings()
    self:UpdateMinimapButton()
end

function BFH:ShowPage(name)
    self.currentPage = name
    self.searchHolder:Hide()

    for n, data in pairs(self.pages) do
        data.holder:SetShown(n == name)
    end

    for n, b in pairs(self.navButtons) do
        if n == name then
            b:SetBackdropColor(0.12,0.055,0.18,1)
            b:SetBackdropBorderColor(unpack(ACCENT))
        else
            b:SetBackdropColor(0.075,0.078,0.092,1)
            b:SetBackdropBorderColor(0.15,0.16,0.19,1)
        end
    end

    self:RefreshConfig()
end

function BFH:RefreshSearch()
    if not self.searchHolder then return end
    local q = self.searchText or ""

    if q == "" then
        self.searchHolder:Hide()
        if self.pages[self.currentPage] then
            self.pages[self.currentPage].holder:Show()
        end
        return
    end

    for _, data in pairs(self.pages) do data.holder:Hide() end
    self.searchHolder:Show()

    local matches = {}
    for _, item in ipairs(self.searchIndex or {}) do
        local haystack = (item.name.." "..item.page.." "..item.keywords):lower()
        if haystack:find(q, 1, true) then table.insert(matches, item) end
    end

    local y = -105
    for i, item in ipairs(matches) do
        local row = self.searchRows[i]
        if not row then
            row = Button(self.searchPage, "", 560, 42, nil)
            row.label:ClearAllPoints()
            row.label:SetPoint("LEFT", 12, 0)
            row.label:SetJustifyH("LEFT")
            self.searchRows[i] = row
        end
        row:SetPoint("TOPLEFT", 30, y)
        row.label:SetText(item.name.."   |cff888a95"..item.page.."|r")
        row:SetScript("OnClick", function()
            self.searchText = ""
            self:ShowPage(item.page)
        end)
        row:Show()
        y = y - 48
    end

    for i = #matches + 1, #self.searchRows do self.searchRows[i]:Hide() end
    self.searchPage:SetHeight(math.max(760, -y + 100))
    for _, button in ipairs(self.closeButtons or {}) do
        if button.UpdateAccent then button:UpdateAccent() end
    end
end

function BFH:RefreshConfig()
    if not self.config then return end
    self:ApplyConfigFont()
    self:ApplyConfigTheme()

    for _, data in pairs(self.pages) do
        if data.controls then
            for _, control in ipairs(data.controls) do
                if control.Refresh then control:Refresh() end
            end
        end
    end

    if self.barStyleButton then
        self.barStyleButton.label:SetText(self.db.barTextureName or "Blizzard")
    end

    if self.fontButton then
        self.fontButton.label:SetText(self.db.fontName or "Friz Quadrata")
        local path = self.db.font or "Fonts\\FRIZQT__.TTF"
        if not self.fontButton.label:SetFont(path, 12, "") then
            self.fontButton.label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
        end
    end

    if self.currentProfileText then
        self.currentProfileText:SetText("Current profile: "..(self.db.activeProfile or "Default"))
    end
    if self.talentStatusText then
        local sr = self:HasSoulReaper()
        local bf = self:HasBlightfall()
        self.talentStatusText:SetText(
            "Talent detection: Soul Reaper " .. (sr and "|cff45ff45active|r" or "|cffff4040not known|r")
            .. "   •   Blightfall " .. (bf and "|cff45ff45active|r" or "|cffff4040not known|r")
        )
    end
end

function BFH:StartAutomaticMenuPreview()
    -- Fail-safe: the settings window must never break just because preview
    -- functionality is unavailable or another module failed to initialise.
    if type(self.ShowPreview) ~= "function" or not self.db then
        return
    end

    local stage
    if self.db.enableSoulReaperBar ~= false then
        stage = "SOUL"
    elseif self.db.enableBlightfallBar ~= false then
        stage = "BLIGHT"
    else
        stage = "SOUL"
    end

    local ok, err = pcall(self.ShowPreview, self, stage)
    if not ok then
        -- Keep the options window usable even if preview itself errors.
        if self.StopStage then
            pcall(self.StopStage, self)
        end
    end
end

function BFH:ToggleConfig()
    if not self.config then return end

    if self.config:IsShown() then
        if self.fontPicker then self.fontPicker:Hide() end
        self.config:Hide()
        if type(self.StopStage) == "function" then
            self:StopStage()
        end
    else
        -- Always open centered as requested.
        self.config:ClearAllPoints()
        self.config:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self.config:SetSize(
            math.max(900, tonumber(self.db.configWidth) or 1040),
            math.max(600, tonumber(self.db.configHeight) or 700)
        )
        self.config:Show()
        self:RefreshConfig()

        if C_Timer and type(C_Timer.After) == "function" then
            C_Timer.After(0, function()
                if BFH.config and BFH.config:IsShown() then
                    BFH:StartAutomaticMenuPreview()
                end
            end)
        else
            self:StartAutomaticMenuPreview()
        end
    end
end
