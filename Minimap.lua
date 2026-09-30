local BFH = _G.Blightfall
if not BFH then return end

local BUTTON_SIZE = 32

local RIM_OFFSET = 10

-- Buttons ride a circle slightly wider than the minimap, as other addons do.
local function GetMinimapRadius()
    if not Minimap then return 70 + RIM_OFFSET end
    local w = Minimap:GetWidth() or 140
    local h = Minimap:GetHeight() or 140
    return math.max(w, h) * 0.5 + RIM_OFFSET
end

-- Places the button on that circle at the saved angle.
local function PositionButton(button, angle)
    if not Minimap then return end
    local radius = GetMinimapRadius()
    local r = math.rad(angle or 225)
    button:ClearAllPoints()
    button:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(r) * radius,
        math.sin(r) * radius
    )
end

-- Crops a texture to a circle.
local function ApplyCircleMask(texture, parent, size)
    local mask = parent:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetSize(size, size)
    mask:SetPoint("CENTER", texture, "CENTER")
    texture:AddMaskTexture(mask)
    return mask
end

function BFH:InitializeMinimapButton()
    if not Minimap then return end
    if self.minimapButton then
        self:UpdateMinimapButton()
        return
    end

    local b = CreateFrame("Button", "BlightfallMinimapButton", Minimap)
    b:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    b:SetClampedToScreen(true)
    b:RegisterForClicks("LeftButtonUp")
    b:RegisterForDrag("LeftButton")

    local outerRing = b:CreateTexture(nil, "BACKGROUND")
    outerRing:SetTexture("Interface\\Buttons\\WHITE8X8")
    outerRing:SetSize(30, 30)
    outerRing:SetPoint("CENTER")
    outerRing:SetVertexColor(0.92, 0.72, 0.16, 1)
    ApplyCircleMask(outerRing, b, 30)

    local innerRing = b:CreateTexture(nil, "BORDER")
    innerRing:SetTexture("Interface\\Buttons\\WHITE8X8")
    innerRing:SetSize(26, 26)
    innerRing:SetPoint("CENTER")
    innerRing:SetVertexColor(0.08, 0.07, 0.055, 1)
    ApplyCircleMask(innerRing, b, 26)

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("CENTER")

    local idle = self.ns.AnimData and self.ns.AnimData.blight_idle
    if idle then
        local page = idle.pages[1]
        local px = page[3] / idle.cell
        icon:SetTexture(page[1], "CLAMP", "CLAMP", "NEAREST")
        icon:SetTexCoord(30 * px, 94 * px, 30 * px, 94 * px)
    else
        icon:SetTexture(self:GetSpellTexture(self.SPELL.BLIGHTFALL))
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    ApplyCircleMask(icon, b, 22)

    local hover = b:CreateTexture(nil, "OVERLAY")
    hover:SetTexture("Interface\\Buttons\\WHITE8X8")
    hover:SetSize(30, 30)
    hover:SetPoint("CENTER")
    hover:SetVertexColor(1, 1, 1, 0)
    ApplyCircleMask(hover, b, 30)

    b.icon = icon
    b.outerRing = outerRing
    b.innerRing = innerRing
    b.hover = hover

    b:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        self.hover:SetVertexColor(1, 1, 1, 0.10)

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(BFH.FULL_NAME, 0.78, 0.38, 1)
        GameTooltip:AddLine("Left-click: Open settings", 1, 1, 1)
        GameTooltip:AddLine("Drag: Move around the minimap rim", 0.72, 0.75, 0.82)
        GameTooltip:Show()
    end)

    b:SetScript("OnLeave", function(self)
        self.hover:SetVertexColor(1, 1, 1, 0)
        GameTooltip:Hide()

        if BFH.db.minimapMouseoverOnly then
            self:SetAlpha(0)
        end
    end)

    b:SetScript("OnClick", function()
        BFH:ToggleConfig()
    end)

    b:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            cx, cy = cx / scale, cy / scale

            local dx, dy = cx - mx, cy - my
            local angle = math.deg(math.atan2(dy, dx))

            BFH.db.minimapAngle = angle
            PositionButton(self, angle)
        end)
    end)

    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        PositionButton(self, BFH.db.minimapAngle)
    end)

    self.minimapButton = b
    PositionButton(b, self.db.minimapAngle)
    self:UpdateMinimapButton()
end

function BFH:UpdateMinimapButton()
    if not self.minimapButton or not self.db then return end

    local b = self.minimapButton
    b:SetShown(self.db.showMinimapButton ~= false)
    PositionButton(b, self.db.minimapAngle)

    if self.db.showMinimapButton == false then return end

    if self.db.minimapMouseoverOnly and not b:IsMouseOver() then
        b:SetAlpha(0)
    else
        b:SetAlpha(1)
    end
end
