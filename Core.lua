local ADDON_NAME, ns = ...
local BFH = CreateFrame("Frame")
_G.Blightfall = BFH
BFH.ns = ns

BFH.VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"
if BFH.VERSION:find("@", 1, true) then BFH.VERSION = "dev" end
BFH.SCHEMA = 102

BFH.MEDIA = "Interface\\AddOns\\Blightfall\\Media\\"

BFH.SPELL = {
    DARK_TRANSFORMATION = 1233448,
    SOUL_REAPER = 343294,
    BLIGHTFALL = 1271967,
    BLIGHTFALL_TALENT = 1271974,
    PUTREFY = 1247378,
}

BFH.DEFAULT_NAMES = {
    SOUL = "Soul Reaper",
    BLIGHT = "Blightfall",
    PUTREFY = "Putrefy",
}

BFH.FULL_NAME = "Blightfall - The Ultimate Death Knight Experience"
BFH.RECOMMENDED_DELAY = 6.2

BFH.LIMITS = {
    SOUL = {1, 15},
    BLIGHT = {1, 8},
}

local FONT_OLDBITZ = BFH.MEDIA .. "Fonts\\Oldbitz.ttf"
local FONT_DTM = BFH.MEDIA .. "Fonts\\DTM-Mono.otf"

BFH.defaults = {
    schemaVersion = BFH.SCHEMA,

    -- General
    locked = true,
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 120,
    showMinimapButton = true,
    minimapMouseoverOnly = false,
    minimapAngle = 225,
    showPutrefy = true,
    soulDelay = 6.2,
    blightDelay = 6.2,

    -- Style: animation
    scale = 100,
    putrefySmall = false,
    flashEnabled = false,
    flashAt = 4,

    -- Style: countdown text (shown while loading)
    counter = {
        show = true,
        font = FONT_DTM,
        fontName = "DTM Mono",
        size = 18,
        outline = "MONOCHROME",
        color = {1, 1, 1, 1},
        shadow = false,
        shadowColor = {0, 0, 0, 1},
        x = 0,
        y = 0,
        precision = 1,
    },

    -- Style: spell name under the animation
    label = {
        show = true,
        font = FONT_OLDBITZ,
        fontName = "Oldbitz",
        size = 14,
        outline = "MONOCHROME",
        color = {0xFC / 255, 0xBC / 255, 0x31 / 255, 1}, -- #FCBC31
        shadow = true,
        shadowColor = {0xCC / 255, 0x44 / 255, 0x19 / 255, 1}, -- #CC4419
        x = 0,
        y = -72,
    },
    names = {
        SOUL = "Soul Reaper",
        BLIGHT = "Blightfall",
        PUTREFY = "Putrefy",
    },

    -- Style: sound
    soundPreset = "default",
    readySound = {
        SOUL = "ready_check",
        BLIGHT = "raid_warning",
    },
    soundEnabled = true,
    countdownStart = 4,
    audioMode = "FILES", -- FILES / TTS
    soundChannel = "Master",
    ttsVolume = 80,
    ttsRate = 0,
}

-- Placeholder "ready" sounds until the custom sound pack arrives. Entries
-- may use `kit` (a SOUNDKIT constant name) or `file` (a path under Media).
BFH.SOUNDS = {
    {key = "none", name = "None"},
    {key = "ready_check", name = "Ready Check", kit = "READY_CHECK"},
    {key = "raid_warning", name = "Raid Warning", kit = "RAID_WARNING"},
    {key = "alarm", name = "Alarm Clock", kit = "ALARM_CLOCK_WARNING_3"},
    {key = "quest_complete", name = "Quest Complete", kit = "IG_QUEST_LIST_COMPLETE"},
    {key = "map_ping", name = "Map Ping", kit = "MAP_PING"},
}

BFH.SOUND_PRESETS = {
    {key = "default", name = "Default", SOUL = "ready_check", BLIGHT = "raid_warning"},
    {key = "subtle", name = "Subtle", SOUL = "map_ping", BLIGHT = "quest_complete"},
    {key = "alarm", name = "Alarm", SOUL = "alarm", BLIGHT = "alarm"},
    {key = "silent", name = "Silent", SOUL = "none", BLIGHT = "none"},
}

local function DeepCopy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, x in pairs(v) do out[k] = DeepCopy(x) end
    return out
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

---------------------------------------------------------------------------
-- Fonts
---------------------------------------------------------------------------

function BFH:GetFonts()
    local list = {
        {name = "Oldbitz", path = FONT_OLDBITZ},
        {name = "DTM Mono", path = FONT_DTM},
        {name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF"},
        {name = "Arial Narrow", path = "Fonts\\ARIALN.TTF"},
        {name = "Skurri", path = "Fonts\\SKURRI.TTF"},
        {name = "Morpheus", path = "Fonts\\MORPHEUS.TTF"},
    }
    local seen = {}
    for _, f in ipairs(list) do seen[f.path:lower()] = true end

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local names = LSM:List("font") or {}
        table.sort(names)
        for _, name in ipairs(names) do
            local path = LSM:Fetch("font", name, true)
            if path and not seen[path:lower()] then
                seen[path:lower()] = true
                list[#list + 1] = {name = name, path = path}
            end
        end
    end
    return list
end

local function RegisterSharedMedia()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end
    LSM:Register("font", "Oldbitz", FONT_OLDBITZ)
    LSM:Register("font", "DTM Mono", FONT_DTM)
end

---------------------------------------------------------------------------
-- Sound
---------------------------------------------------------------------------

function BFH:GetSound(key)
    for _, s in ipairs(self.SOUNDS) do
        if s.key == key then return s end
    end
end

function BFH:PlaySoundEntry(key)
    local s = self:GetSound(key)
    if not s then return end
    local channel = self.db.soundChannel or "Master"
    if s.kit and SOUNDKIT and SOUNDKIT[s.kit] then
        PlaySound(SOUNDKIT[s.kit], channel)
    elseif s.file then
        PlaySoundFile(self.MEDIA .. s.file, channel)
    end
end

function BFH:PlayReadySound(stage)
    local key = self.db.readySound and self.db.readySound[stage]
    if key then self:PlaySoundEntry(key) end
end

function BFH:ApplySoundPreset(presetKey)
    for _, p in ipairs(self.SOUND_PRESETS) do
        if p.key == presetKey then
            self.db.soundPreset = p.key
            self.db.readySound.SOUL = p.SOUL
            self.db.readySound.BLIGHT = p.BLIGHT
            return
        end
    end
end

-- The preset shown in the UI is whichever one matches the current picks.
function BFH:GetMatchingPreset()
    for _, p in ipairs(self.SOUND_PRESETS) do
        if p.SOUL == self.db.readySound.SOUL and p.BLIGHT == self.db.readySound.BLIGHT then
            return p.key
        end
    end
    return "custom"
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

function BFH:SpeakText(text)
    local voiceID = self:GetTTSVoiceID()
    if not voiceID or not C_VoiceChat or not C_VoiceChat.SpeakText then return end
    self:StopTTS()
    pcall(C_VoiceChat.SpeakText, voiceID, text,
        tonumber(self.db.ttsRate) or 0, tonumber(self.db.ttsVolume) or 80, false)
end

function BFH:PlayCountdown(number)
    if not self.db.soundEnabled then return end
    if number < 1 or number > 10 then return end

    if self.db.audioMode == "TTS" then
        self:SpeakText(tostring(number))
    else
        PlaySoundFile(self:GetSoundPath(number), self.db.soundChannel or "Master")
    end
end

function BFH:GetSpellTexture(spellID)
    local texture
    if C_Spell and C_Spell.GetSpellTexture then
        texture = C_Spell.GetSpellTexture(spellID)
    end
    return texture or 134400
end

---------------------------------------------------------------------------
-- Talents
---------------------------------------------------------------------------

function BFH:IsSpellAvailable(spellID)
    if not spellID then return false end

    if type(IsPlayerSpell) == "function" then
        local ok, known = pcall(IsPlayerSpell, spellID)
        if ok and known then return true end
    end

    if type(IsSpellKnown) == "function" then
        local ok, known = pcall(IsSpellKnown, spellID)
        if ok and known then return true end
    end

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
    return self:IsSpellAvailable(self.SPELL.BLIGHTFALL)
        or self:IsSpellAvailable(self.SPELL.BLIGHTFALL_TALENT)
end

function BFH:HasPutrefy()
    return self:IsSpellAvailable(self.SPELL.PUTREFY)
end

function BFH:RefreshTalentState()
    self.hasSoulReaper = self:HasSoulReaper()
    self.hasBlightfall = self:HasBlightfall()
    self.hasPutrefy = self:HasPutrefy()

    if not self.preview then
        if (self.stage == "SOUL" and not self.hasSoulReaper)
            or (self.stage == "BLIGHT" and not self.hasBlightfall)
            or (self.stage == "PUTREFY" and not self.hasPutrefy) then
            self:ClearMain()
        end
    end

    if self.RefreshConfig then self:RefreshConfig() end
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- Midnight hides many combat values from addons ("secret values"), including
-- the pet's auras, so the sequence is driven only by the player's own casts.
-- Anything secret must be ignored, never compared or used as a table key.
local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) and true or false
end
BFH.IsSecret = IsSecret

-- Debug output toggled with /bf debug.
function BFH:Debug(...)
    if self.debug then print("|cff9f1cffBlightfall debug:|r", ...) end
end

---------------------------------------------------------------------------
-- Sequence: DT -> Soul Reaper -> Blightfall -> Putrefy
---------------------------------------------------------------------------

function BFH:OnDarkTransformation()
    self:StopPreview()
    self:ClearAll()

    if self.hasSoulReaper then
        self:ShowStage("SOUL")
    elseif self.hasBlightfall then
        self:ShowStage("BLIGHT")
    end
end

function BFH:OnSoulReaper()
    if self.stage ~= "SOUL" then return end
    self:PlayOnUse("SOUL")
    if self.hasBlightfall then
        self:ShowStage("BLIGHT")
    else
        self:ClearMain()
    end
end

function BFH:OnBlightfall()
    if self.stage ~= "BLIGHT" then return end
    self:PlayOnUse("BLIGHT")
    if self.db.showPutrefy and self.hasPutrefy then
        self:ShowPutrefy(0.5)
    else
        self:ClearMain()
    end
end

function BFH:OnPutrefy()
    if self.stage ~= "PUTREFY" then return end
    if not self:IsPutrefyPending() then
        self:PlayOnUse("PUTREFY")
    end
    self:ClearMain()
end

function BFH:HandleSpell(spellID)
    if IsSecret(spellID) then
        self:Debug("cast with hidden spell ID ignored")
        return
    end
    self.hasSoulReaper = self:HasSoulReaper()
    self.hasBlightfall = self:HasBlightfall()
    self.hasPutrefy = self:HasPutrefy()

    if spellID == self.SPELL.DARK_TRANSFORMATION then
        self:Debug("Dark Transformation cast")
        self:OnDarkTransformation()
        return
    end

    if self.preview then return end

    if spellID == self.SPELL.SOUL_REAPER then
        self:Debug("Soul Reaper cast, stage:", tostring(self.stage))
        self:OnSoulReaper()
    elseif spellID == self.SPELL.BLIGHTFALL then
        self:Debug("Blightfall cast, stage:", tostring(self.stage))
        self:OnBlightfall()
    elseif spellID == self.SPELL.PUTREFY then
        self:Debug("Putrefy cast, stage:", tostring(self.stage))
        self:OnPutrefy()
    end
end

function BFH:ResetSequence()
    if not self.preview then self:ClearAll() end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

BFH:RegisterEvent("ADDON_LOADED")
BFH:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
BFH:RegisterEvent("PLAYER_ENTERING_WORLD")
BFH:RegisterEvent("PLAYER_TALENT_UPDATE")
BFH:RegisterEvent("SPELLS_CHANGED")
BFH:RegisterEvent("TRAIT_CONFIG_UPDATED")

BFH:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON_NAME then return end

        -- Settings from before the animation redesign don't carry over.
        if type(BlightfallDB) ~= "table" or (tonumber(BlightfallDB.schemaVersion) or 0) < self.SCHEMA then
            BlightfallDB = {}
        end
        CopyDefaults(self.defaults, BlightfallDB)
        BlightfallDB.schemaVersion = self.SCHEMA
        self.db = BlightfallDB

        RegisterSharedMedia()
        if self.InitializeDisplay then self:InitializeDisplay() end
        if self.InitializeMinimapButton then self:InitializeMinimapButton() end

        SLASH_BLIGHTFALL1 = "/blightfall"
        SLASH_BLIGHTFALL2 = "/bf"
        SlashCmdList.BLIGHTFALL = function(msg)
            msg = (msg or ""):lower():match("^%s*(.-)%s*$")
            if msg == "unlock" or msg == "move" then
                self:SetLocked(false)
            elseif msg == "lock" then
                self:SetLocked(true)
            elseif msg == "test" then
                self:StartPreview("SOUL")
            elseif msg == "stop" then
                self:StopPreview()
            elseif msg == "debug" then
                self.debug = not self.debug
                print("|cff9f1cffBlightfall|r debug " .. (self.debug and "on" or "off"))
            else
                self:ToggleConfig()
            end
        end

        self:RefreshTalentState()
        print("|cff9f1cffBlightfall|r v" .. self.VERSION .. " loaded. Type |cffffffff/bf|r for settings.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:ResetSequence()
        self:RefreshTalentState()
    elseif event == "PLAYER_TALENT_UPDATE" or event == "SPELLS_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        self:RefreshTalentState()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then self:HandleSpell(spellID) end
    end
end)
