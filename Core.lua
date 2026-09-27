local ADDON_NAME = ...
local BFH = CreateFrame("Frame")
_G.Blightfall = BFH

BFH.VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"
if BFH.VERSION:find("@", 1, true) then BFH.VERSION = "dev" end
BFH.SCHEMA = 15

BFH.SPELL = {
    DARK_TRANSFORMATION = 1233448,
    DARK_TRANSFORMATION_AURA = 1235391,
    SOUL_REAPER = 343294,
    BLIGHTFALL = 1271967,
    BLIGHTFALL_TALENT = 1271974,
    PUTREFY = 1247378,
}

BFH.defaults = {
    schemaVersion = BFH.SCHEMA,

    enabled = true,
    displayMode = "BAR",
    locked = true,

    showMinimapButton = true,
    minimapMouseoverOnly = false,
    minimapAngle = 225,

    soulDelay = 7.0,
    blightDelay = 6.0,
    putrefyDelay = 10.0,
    countdownStart = 4,
    precision = 1,
    cancelAfterDT = true,
    dtCancelGrace = 5,
    enableSoulReaperBar = true,
    enableBlightfallBar = true,
    enablePutrefyBar = true,
    disableInDungeons = false,

    soundEnabled = true,
    audioMode = "FILES", -- FILES / TTS
    soundChannel = "Master",
    ttsVolume = 80,
    ttsRate = 0,
    ttsVoiceID = nil,

    scale = 1.00,
    barWidth = 200,
    barHeight = 20,
    barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
    barTextureName = "Blizzard",
    barReverseFill = false,
    barSmooth = true,
    showBarText = true,
    barTextPosition = "LEFT", -- LEFT / CENTER / RIGHT
    showIcon = true,
    iconPosition = "LEFT",
    iconSize = 20,
    iconOnlySize = 64,
    iconCountdownPosition = "BELOW", -- BELOW / CENTER
    iconCountdownFontSize = 18,
    iconCountdownColor = {1, 1, 1, 1},
    textOnlyWidth = 220,
    textOnlyHeight = 34,

    font = "Fonts\\FRIZQT__.TTF",
    fontName = "Friz Quadrata",
    labelFontSize = 14,
    timerFontSize = 14,

    showSpark = true,
    borderEnabled = true,
    barBorderEnabled = true,
    barBorderSize = 1,
    barBorderColor = {0, 0, 0, 1},
    iconBorderEnabled = true,
    iconBorderSize = 1,
    iconBorderColor = {0, 0, 0, 1},
    backgroundAlpha = 0.90,
    barBackgroundColor = {0.018, 0.018, 0.022, 1},

    soulColor = {0x1C/255, 0x28/255, 0xFF/255, 1},
    blightColor = {0x9F/255, 0x1C/255, 0xFF/255, 1},
    putrefyColor = {0x45/255, 0xFF/255, 0x1C/255, 1},
    dangerColor = {0xFF/255, 0x00/255, 0x10/255, 1},

    menuBackgroundColor = {0.025, 0.027, 0.034, 0.985},
    menuPanelColor = {0.052, 0.055, 0.066, 0.98},
    menuAccentColor = {0.62, 0.11, 1.00, 1},

    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,

    configWidth = 1040,
    configHeight = 700,

    activeProfile = "Default",
    profiles = { Default = {} },
}

local function DeepCopy(src)
    if type(src) ~= "table" then return src end
    local dst = {}
    for k, v in pairs(src) do dst[k] = DeepCopy(v) end
    return dst
end
BFH.DeepCopy = DeepCopy

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end
BFH.CopyDefaults = CopyDefaults

local function Migrate(db)
    local old = tonumber(db.schemaVersion) or 0
    -- v2.7.0 modular timer / dungeon settings
    if old < 15 then
        if db.enableSoulReaperBar == nil then db.enableSoulReaperBar = true end
        if db.enableBlightfallBar == nil then db.enableBlightfallBar = true end
        if db.disableInDungeons == nil then db.disableInDungeons = false end
    end

    -- v2.6.3 DT pet aura + configurable grace
    if old < 13 then
        if db.cancelAfterDT == nil then db.cancelAfterDT = true end
        db.dtCancelGrace = db.dtCancelGrace or 5
    end

    -- v2.6.0 Dark Transformation expiry guard
    if old < 12 then
        if db.cancelAfterDT == nil then db.cancelAfterDT = true end
    end

    -- v2.4.1 bar style settings
    if old < 10 then
        db.barTexture = db.barTexture or "Interface\\TargetingFrame\\UI-StatusBar"
        db.barTextureName = db.barTextureName or "Blizzard"
        if db.barReverseFill == nil then db.barReverseFill = false end
        if db.barSmooth == nil then db.barSmooth = true end
    end

    -- v2.4.0 text/icon display settings
    if old < 9 then
        if db.showBarText == nil then db.showBarText = true end
        db.barTextPosition = db.barTextPosition or "LEFT"
        db.iconCountdownPosition = db.iconCountdownPosition or "BELOW"
        db.iconCountdownFontSize = db.iconCountdownFontSize or 18
        db.iconCountdownColor = db.iconCountdownColor or {1,1,1,1}
    end

    -- v2.3.0 border settings
    if old < 8 then
        if db.barBorderEnabled == nil then db.barBorderEnabled = true end
        db.barBorderSize = db.barBorderSize or 1
        db.barBorderColor = db.barBorderColor or {0,0,0,1}
        if db.iconBorderEnabled == nil then db.iconBorderEnabled = true end
        db.iconBorderSize = db.iconBorderSize or 1
        db.iconBorderColor = db.iconBorderColor or {0,0,0,1}
    end


    -- v2.2.8: the previous shipped default was 7.0s. Existing installs
    -- retain SavedVariables, so migrate that old default to the new 6.0s default.
    -- Values other than exactly 7.0 are treated as user customisations and preserved.
    if old < 7 and (db.blightDelay == 7 or db.blightDelay == 7.0) then
        db.blightDelay = 6.0
    end

    if old < 6 then
        db.soulColor = {0x1C/255, 0x28/255, 0xFF/255, 1}
        db.blightColor = {0x9F/255, 0x1C/255, 0xFF/255, 1}
        db.dangerColor = {0xFF/255, 0x00/255, 0x10/255, 1}
        db.barBackgroundColor = {0.018, 0.018, 0.022, 1}
        db.menuBackgroundColor = {0.025, 0.027, 0.034, 0.985}
        db.menuPanelColor = {0.052, 0.055, 0.066, 0.98}
        db.menuAccentColor = {0.62, 0.11, 1.00, 1}
        db.showIcon = true
        db.iconPosition = "LEFT"
        db.showMinimapButton = true
        db.audioMode = db.audioMode or "FILES"
        db.ttsVolume = db.ttsVolume or 80
        db.ttsRate = db.ttsRate or 0
        db.configWidth = math.max(900, tonumber(db.configWidth) or 1040)
        db.configHeight = math.max(600, tonumber(db.configHeight) or 700)
        db.schemaVersion = 6
    end

    if old < BFH.SCHEMA then
        db.schemaVersion = BFH.SCHEMA
    end
end

function BFH:GetSpellTexture(spellID)
    local texture
    if C_Spell and C_Spell.GetSpellTexture then
        texture = C_Spell.GetSpellTexture(spellID)
    end
    if not texture and C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        texture = info and info.iconID
    end
    if not texture and GetSpellTexture then
        texture = GetSpellTexture(spellID)
    end
    return texture or 134400
end

function BFH:GetSoundPath(number)
    return string.format("Interface\\AddOns\\Blightfall\\Sounds\\%d.ogg", number)
end

function BFH:GetTTSVoices()
    if C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local ok, voices = pcall(C_VoiceChat.GetTtsVoices)
        if ok and type(voices) == "table" then return voices end
    end
    return {}
end

function BFH:GetTTSVoiceID()
    local voices = self:GetTTSVoices()
    if #voices == 0 then return nil end

    if self.db.ttsVoiceID then
        for _, voice in ipairs(voices) do
            if voice.voiceID == self.db.ttsVoiceID then
                return self.db.ttsVoiceID
            end
        end
    end

    self.db.ttsVoiceID = voices[1].voiceID
    return self.db.ttsVoiceID
end

function BFH:StopTTS()
    if C_VoiceChat and C_VoiceChat.StopSpeakingText then
        pcall(C_VoiceChat.StopSpeakingText)
    end
end

function BFH:PlayCountdown(number)
    if not self.db.soundEnabled then return end
    if number < 1 or number > 10 then return end

    if self.db.audioMode == "TTS" then
        local voiceID = self:GetTTSVoiceID()
        if not voiceID or not C_VoiceChat or not C_VoiceChat.SpeakText then return end
        self:StopTTS()
        pcall(
            C_VoiceChat.SpeakText,
            voiceID,
            tostring(number),
            tonumber(self.db.ttsRate) or 0,
            tonumber(self.db.ttsVolume) or 80,
            false
        )
    else
        PlaySoundFile(self:GetSoundPath(number), self.db.soundChannel or "Master")
    end
end

function BFH:IsSpellAvailable(spellID)
    if not spellID then return false end

    -- Retail WoW commonly exposes IsPlayerSpell for learned/talented spells.
    if type(IsPlayerSpell) == "function" then
        local ok, known = pcall(IsPlayerSpell, spellID)
        if ok and known then return true end
    end

    -- Older/global fallback.
    if type(IsSpellKnown) == "function" then
        local ok, known = pcall(IsSpellKnown, spellID)
        if ok and known then return true end
    end

    -- Modern spellbook fallback if available on the client.
    if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID)
        if ok and known then return true end
    end

    return false
end

function BFH:HasSoulReaper()
    return self:IsSpellAvailable(self.SPELL.SOUL_REAPER)
end

function BFH:HasBlightfall()
    -- Check both the cast spell and the passive/talent node spell.
    return self:IsSpellAvailable(self.SPELL.BLIGHTFALL)
        or self:IsSpellAvailable(self.SPELL.BLIGHTFALL_TALENT)
end

function BFH:HasPutrefy()
    return self:IsSpellAvailable(self.SPELL.PUTREFY)
end

-- True when a Putrefy timer should follow Blightfall, so the sequence must
-- stay armed through Blightfall even if the Blightfall bar itself is hidden.
function BFH:TracksPutrefy()
    return self.hasPutrefy and self.db.enablePutrefyBar
end

function BFH:RefreshTalentState()
    self.hasSoulReaper = self:HasSoulReaper()
    self.hasBlightfall = self:HasBlightfall()
    self.hasPutrefy = self:HasPutrefy()

    -- If talents change while a timer is active, remove a timer for a spell
    -- the player no longer knows.
    if self.stage == "SOUL" and not self.hasSoulReaper then
        self:StopStage()
    elseif self.stage == "BLIGHT" and not self.hasBlightfall then
        self:StopStage()
    elseif self.stage == "PUTREFY" and not self.hasPutrefy then
        self:StopStage()
    end

    if self.RefreshConfig then
        self:RefreshConfig()
    end
end

function BFH:GetDarkTransformationName()
    if C_Spell and type(C_Spell.GetSpellName) == "function" then
        local ok, name = pcall(C_Spell.GetSpellName, self.SPELL.DARK_TRANSFORMATION)
        if ok and name then return name end
    end

    if type(GetSpellInfo) == "function" then
        local name = GetSpellInfo(self.SPELL.DARK_TRANSFORMATION)
        if name then return name end
    end

    return "Dark Transformation"
end

function BFH:HasDarkTransformationAura()
    if not UnitExists("pet") then
        return false
    end

    local wantedName = self:GetDarkTransformationName()
    local auraIDs = {
        [self.SPELL.DARK_TRANSFORMATION_AURA] = true,
        [self.SPELL.DARK_TRANSFORMATION] = true,
        [63560] = true, -- legacy/client fallback
    }

    -- Modern aura iteration. This checks both ID and the visible aura name.
    if C_UnitAuras and type(C_UnitAuras.GetAuraDataByIndex) == "function" then
        for i = 1, 60 do
            local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "pet", i, "HELPFUL")
            if not ok or not aura then break end

            local id = aura.spellId or aura.spellID
            local name = aura.name
            if auraIDs[id] or (name and wantedName and name == wantedName) then
                return true
            end
        end
    end

    -- AuraUtil fallback by known IDs.
    if AuraUtil and type(AuraUtil.FindAuraBySpellID) == "function" then
        for spellID in pairs(auraIDs) do
            local ok, aura = pcall(AuraUtil.FindAuraBySpellID, spellID, "pet", "HELPFUL")
            if ok and aura then return true end
        end
    end

    -- Older UnitAura fallback, also checking name.
    if type(UnitAura) == "function" then
        for i = 1, 60 do
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura("pet", i, "HELPFUL")
            if not name then break end
            if auraIDs[spellID] or (wantedName and name == wantedName) then
                return true
            end
        end
    end

    return false
end

function BFH:CancelDarkTransformationWatcher()
    if self.dtWatcher then
        self.dtWatcher:Cancel()
        self.dtWatcher = nil
    end
end

function BFH:ExpireCurrentSequenceAfterGrace()
    if not self.db or not self.db.cancelAfterDT then return end
    if not self.sequenceArmed or self.sequenceExpired then return end
    if self.dtGracePending then return end

    self.dtGracePending = true
    self.dtAuraMissing = true

    local token = self.sequenceToken
    local grace = math.max(0, math.min(10, tonumber(self.db.dtCancelGrace) or 5))

    local function Expire()
        if not BFH.db or not BFH.db.cancelAfterDT then
            BFH.dtGracePending = false
            return
        end

        if BFH.sequenceToken ~= token or not BFH.sequenceArmed or BFH.sequenceExpired then
            return
        end

        -- If DT returned before the grace period elapsed, keep the sequence alive.
        if BFH:HasDarkTransformationAura() then
            BFH.dtAuraSeen = true
            BFH.dtAuraMissing = false
            BFH.dtGracePending = false
            return
        end

        BFH.sequenceExpired = true
        BFH:ResetSequence()
    end

    if grace <= 0 then
        Expire()
    else
        C_Timer.After(grace, Expire)
    end
end

function BFH:CheckDarkTransformationAura()
    if not self.db or not self.db.cancelAfterDT then return end
    if not self.sequenceArmed or self.sequenceExpired then return end

    local active = self:HasDarkTransformationAura()

    if active then
        self.dtAuraSeen = true
        self.dtAuraMissing = false
        self.dtGracePending = false
        return
    end

    -- Only treat absence as expiry after DT has actually been observed on the pet.
    if self.dtAuraSeen then
        self:ExpireCurrentSequenceAfterGrace()
    end
end

function BFH:StartDarkTransformationWatcher()
    self:CancelDarkTransformationWatcher()

    if not self.db or not self.db.cancelAfterDT then return end

    -- Polling makes this reliable even if UNIT_AURA does not fire for the hidden
    -- transformed-ghoul aura on a particular client build.
    self.dtWatcher = C_Timer.NewTicker(0.20, function()
        if not BFH.sequenceArmed or BFH.sequenceExpired then
            BFH:CancelDarkTransformationWatcher()
            return
        end
        BFH:CheckDarkTransformationAura()
    end)
end


function BFH:IsDisabledByInstance()
    if not self.db or not self.db.disableInDungeons then
        return false
    end

    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "party"
end

function BFH:RefreshInstanceState()
    local disabled = self:IsDisabledByInstance()
    self.instanceSuppressed = disabled

    if disabled then
        -- Clear any active combat sequence immediately on entering a dungeon.
        self:ResetSequence()
    end

    if self.RefreshConfig then
        self:RefreshConfig()
    end
end

function BFH:HandleSpell(spellID)
    if not self.db.enabled then return end
    if type(self.IsDisabledByInstance) == "function" and self:IsDisabledByInstance() then return end

    self.hasSoulReaper = self:HasSoulReaper()
    self.hasBlightfall = self:HasBlightfall()
    self.hasPutrefy = self:HasPutrefy()

    if spellID == self.SPELL.DARK_TRANSFORMATION then
        self.sequenceToken = (self.sequenceToken or 0) + 1
        self.sequenceArmed = true
        self.sequenceExpired = false
        self.soulUsed = false
        self.blightUsed = false
        self.dtAuraSeen = false
        self.dtAuraMissing = false
        self.dtGracePending = false

        self:StartDarkTransformationWatcher()
        local token = self.sequenceToken
        C_Timer.After(0.10, function()
            if BFH.sequenceToken == token and BFH.sequenceArmed then BFH:CheckDarkTransformationAura() end
        end)

        if self.hasSoulReaper then
            if self.db.enableSoulReaperBar then self:StartStage("SOUL", self.db.soulDelay) else self:StopStage() end
        elseif self.hasBlightfall then
            self.soulUsed = true
            if self.db.enableBlightfallBar then
                self:StartStage("BLIGHT", self.db.blightDelay)
            else
                self:StopStage()
                if not self:TracksPutrefy() then self.sequenceArmed = false end
            end
        else
            self.sequenceArmed = false
            self:StopStage()
        end
        return
    end

    if spellID == self.SPELL.SOUL_REAPER then
        if not self.sequenceArmed or self.sequenceExpired then return end
        if not self.soulUsed and self.hasSoulReaper then
            self.soulUsed = true
            if self.stage == "SOUL" then self:StopStage() end
            if self.hasBlightfall and self.sequenceArmed and not self.sequenceExpired then
                if self.db.enableBlightfallBar then
                    self:StartStage("BLIGHT", self.db.blightDelay)
                elseif not self:TracksPutrefy() then
                    self.sequenceArmed = false
                end
            else self.sequenceArmed=false end
        end
        return
    end

    if spellID == self.SPELL.BLIGHTFALL then
        if self.sequenceArmed and self.soulUsed and not self.blightUsed and self.hasBlightfall then
            self.blightUsed = true
            if self.stage == "BLIGHT" then self:StopStage() end
            -- The sequence stays armed through Putrefy so the Dark
            -- Transformation watcher can still cancel it when DT ends.
            if self:TracksPutrefy() then
                self:StartStage("PUTREFY", self.db.putrefyDelay)
            else
                self.sequenceArmed = false
            end
        end
        return
    end

    if spellID == self.SPELL.PUTREFY then
        if self.stage == "PUTREFY" and not self.preview then
            self:StopStage()
            self.sequenceArmed = false
        end
    end
end

function BFH:ResetSequence()
    self.sequenceToken = (self.sequenceToken or 0) + 1
    self.sequenceArmed = false
    self.sequenceExpired = true
    self.soulUsed = false
    self.blightUsed = false
    self.dtAuraSeen = false
    self.dtAuraMissing = false
    self.dtGracePending = false
    self:CancelDarkTransformationWatcher()
    if self.StopStage then self:StopStage() end
end

BFH:RegisterEvent("ADDON_LOADED")
BFH:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
BFH:RegisterEvent("UNIT_AURA")
BFH:RegisterEvent("PET_BAR_UPDATE")
BFH:RegisterEvent("UNIT_PET")
BFH:RegisterEvent("PLAYER_ENTERING_WORLD")
BFH:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
BFH:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BFH:RegisterEvent("PLAYER_TALENT_UPDATE")
BFH:RegisterEvent("SPELLS_CHANGED")
BFH:RegisterEvent("TRAIT_CONFIG_UPDATED")

BFH:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON_NAME then return end

        BlightfallDB = BlightfallDB or {}
        CopyDefaults(self.defaults, BlightfallDB)
        Migrate(BlightfallDB)
        self.db = BlightfallDB

        if self.InitializeDisplay then self:InitializeDisplay() end
        if self.InitializeMinimapButton then self:InitializeMinimapButton() end
        if self.InitializeConfig then self:InitializeConfig() end

        SLASH_BLIGHTFALL1 = "/blightfall"
        SLASH_BLIGHTFALL2 = "/bf"
        SlashCmdList.BLIGHTFALL = function(msg)
            msg = (msg or ""):lower():match("^%s*(.-)%s*$")
            if msg == "unlock" then
                self.db.locked = false
                self:ApplyDisplaySettings()
                self:ShowPreview("SOUL")
            elseif msg == "lock" then
                self.db.locked = true
                self:ApplyDisplaySettings()
                self:StopStage()
            elseif msg == "test" then
                self:ShowPreview("SOUL")
            elseif msg == "stop" then
                self:StopStage()
            else
                self:ToggleConfig()
            end
        end

        self:RefreshTalentState()
        print("|cff9f1cffBlightfall|r v"..self.VERSION.." loaded. Type |cffffffff/bf|r for settings.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:ResetSequence()
        self:RefreshTalentState()
        if type(self.RefreshInstanceState) == "function" then self:RefreshInstanceState() end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_DIFFICULTY_CHANGED" then
        self:RefreshInstanceState()
    elseif event == "PLAYER_TALENT_UPDATE" or event == "SPELLS_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        self:RefreshTalentState()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "pet" then
            self:CheckDarkTransformationAura()
        end
    elseif event == "UNIT_PET" or event == "PET_BAR_UPDATE" then
        self:CheckDarkTransformationAura()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then self:HandleSpell(spellID) end
    end
end)
