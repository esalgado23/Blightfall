local ADDON_NAME, ns = ...
local BFH = CreateFrame("Frame")
_G.Blightfall = BFH
BFH.ns = ns

BFH.VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"
if BFH.VERSION:find("@", 1, true) then BFH.VERSION = "dev" end
BFH.SCHEMA = 107

local RESET_BELOW_SCHEMA = 102

BFH.MEDIA = "Interface\\AddOns\\Blightfall\\Media\\"

local CELEBRATION_DELAY = 0.267

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
BFH.RECOMMENDED = {SOUL = 9.5, BLIGHT = 6.0}

BFH.LIMITS = {
    SOUL = {1, 15},
    BLIGHT = {1, 8},
}

local FONT_OLDBITZ = BFH.MEDIA .. "Fonts\\Oldbitz.ttf"
local FONT_DTM = BFH.MEDIA .. "Fonts\\DTM-Mono.otf"

BFH.defaults = {
    schemaVersion = BFH.SCHEMA,

    locked = true,
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 120,
    showMinimapButton = true,
    minimapMouseoverOnly = false,
    minimapAngle = 225,
    showPutrefy = true,
    soulDelay = 9.5,
    blightDelay = 6.0,

    scale = 100,
    putrefySmall = false,
    flashEnabled = false,
    flashAt = 4,
    flashReady = false,

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

    label = {
        show = true,
        font = FONT_OLDBITZ,
        fontName = "Oldbitz",
        size = 14,
        outline = "MONOCHROME",
        color = {0xFC / 255, 0xBC / 255, 0x31 / 255, 1},
        shadow = true,
        shadowColor = {0xCC / 255, 0x44 / 255, 0x19 / 255, 1},
        x = 0,
        y = -72,
    },
    names = {
        SOUL = "Soul Reaper",
        BLIGHT = "Blightfall",
        PUTREFY = "Putrefy",
    },

    soundPreset = "custom",
    custom = {
        sounds = {
            SOUL_READY = "zelda_low_health",
            BLIGHT_READY = "zelda_tower",
        },
        cardBurn = true,
    },
    majoraCardBurn = true,
    celebrationEnabled = true,
    celebrationSound = "helios_rap",
    celebrationOffInstances = false,
    soundEnabled = true,
    countdownStart = 4,
    audioMode = "FILES",
    soundChannel = "Master",
    ttsVolume = 80,
    ttsRate = 0,
}

BFH.SOUND_EVENT_NAMES = {
    SOUL_READY = "Soul Reaper ready",
    SOUL_END = "After Soul Reaper",
    BLIGHT_READY = "Blightfall ready",
    BLIGHT_END = "After Blightfall",
    PUTREFY_END = "After Putrefy",
}

BFH.SOUNDS = {
    {key = "none", name = "None"},
    {key = "combo_1", name = "Combo 1", file = "Sounds\\combo_1.ogg", dur = 0.47},
    {key = "combo_2", name = "Combo 2", file = "Sounds\\combo_2.ogg", dur = 0.39},
    {key = "combo_3", name = "Combo 3", file = "Sounds\\combo_3.ogg", dur = 0.37},
    {key = "combo_4", name = "Combo 4", file = "Sounds\\combo_4.ogg", dur = 0.62},
    {key = "combo_5", name = "Combo 5", file = "Sounds\\combo_5.ogg", dur = 1.04},
    {key = "helios_rap", name = "Helios Rap", file = "Sounds\\helios_rap.ogg", dur = 9.13, hidden = true},
    {key = "zelda_low_health", name = "Zelda Low Health", file = "Sounds\\zelda_low_health.ogg", dur = 1.50},
    {key = "zelda_tower", name = "Zelda Tower", file = "Sounds\\zelda_tower.ogg", dur = 4.69},
    {key = "zelda_shrine", name = "Zelda Shrine", file = "Sounds\\zelda_shrine.ogg", dur = 3.17},
    {key = "zelda_sensor", name = "Zelda Sensor", file = "Sounds\\zelda_sensor.ogg", dur = 1.10},
    {key = "zelda_blip", name = "Zelda Blip", file = "Sounds\\zelda_blip.ogg", dur = 0.11},
    {key = "bomb_loading", name = "Bomb Loading", file = "Sounds\\bomb_loading.ogg", dur = 0.53},
    {key = "bomb_ready", name = "Bomb Ready", file = "Sounds\\bomb_car.ogg", dur = 0.52},
    {key = "isaac_1up", name = "Isaac 1up", file = "Sounds\\isaac_1up.ogg", dur = 0.29},
    {key = "isaac_angel_blast", name = "Isaac Angel Blast", file = "Sounds\\isaac_angel_blast1.ogg", dur = 2.11},
    {key = "isaac_battery", name = "Isaac Battery Charge", file = "Sounds\\isaac_battery_charge.ogg", dur = 0.69},
    {key = "isaac_beep", name = "Isaac Beep", file = "Sounds\\isaac_beep.ogg", dur = 0.08},
    {key = "isaac_laser", name = "Isaac Laser", file = "Sounds\\isaac_laser.ogg", dur = 1.47},
    {key = "isaac_lightning", name = "Isaac Lightning", file = "Sounds\\isaac_lightning.ogg", dur = 0.74},
    {key = "isaac_plop", name = "Isaac Plop", file = "Sounds\\isaac_plop.ogg", dur = 0.14},
    {key = "isaac_reaper", name = "Isaac Reaper", file = "Sounds\\isaac_reaper.ogg", dur = 2.40},
    {key = "isaac_soul", name = "Isaac Soul", file = "Sounds\\isaac_soul.ogg", dur = 0.84},
    {key = "isaac_thumbs_down", name = "Isaac Thumbs Down", file = "Sounds\\isaac_thumbs_down.ogg", dur = 0.38},
    {key = "isaac_thumbs_up", name = "Isaac Thumbs Up", file = "Sounds\\isaac_thumbs_up.ogg", dur = 0.19},
    {key = "isaac_unholy", name = "Isaac Unholy", file = "Sounds\\isaac_unholy.ogg", dur = 1.42},
    {key = "isaac_vamp", name = "Isaac Vamp", file = "Sounds\\isaac_vamp.ogg", dur = 0.69},
    {key = "card_burn", name = "Card Burn", file = "Sounds\\card_burn.ogg", hidden = true},
    {key = "card_burn_2", name = "Card Burn 2", file = "Sounds\\card_burn_2.ogg", hidden = true},
    {key = "card_burn_3", name = "Card Burn 3", file = "Sounds\\card_burn_3.ogg", hidden = true},
    {key = "death_card", name = "Death Card", file = "Sounds\\isaacc_death_card.ogg", hidden = true},
}

BFH.CARD_BURN = {"card_burn", "card_burn_2", "card_burn_3", "death_card"}

BFH.SOUND_BY_KEY = {}
for _, entry in ipairs(BFH.SOUNDS) do BFH.SOUND_BY_KEY[entry.key] = entry end

BFH.SOUND_PRESETS = {
    {key = "custom", name = "Custom mode"},
    {key = "majora", name = "Majora", sounds = {
        SOUL_READY = "zelda_low_health", BLIGHT_READY = "zelda_tower"}},
    {key = "uma", name = "Umamusume: Rider of the Apocalypse", combo = true, sounds = {
        SOUL_READY = "combo_1", SOUL_END = "combo_2",
        BLIGHT_READY = "combo_3", BLIGHT_END = "combo_4", PUTREFY_END = "combo_5"}},
}

BFH.CHANNEL_CVAR = {
    Master = "Sound_MasterVolume",
    SFX = "Sound_SFXVolume",
    Music = "Sound_MusicVolume",
    Ambience = "Sound_AmbienceVolume",
    Dialog = "Sound_DialogVolume",
}

local function DeepCopy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, x in pairs(v) do out[k] = DeepCopy(x) end
    return out
end
BFH.DeepCopy = DeepCopy

-- Fills in any setting the saved table is missing.
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

-- Bundled fonts first, then WoW's own and anything LibSharedMedia offers.
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

-- Shares the bundled fonts with other addons.
local function RegisterSharedMedia(_)
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end
    LSM:Register("font", "Oldbitz", FONT_OLDBITZ)
    LSM:Register("font", "DTM Mono", FONT_DTM)
end

function BFH:GetSound(key)
    return self.SOUND_BY_KEY[key]
end

function BFH:GetPreset(key)
    for _, p in ipairs(self.SOUND_PRESETS) do
        if p.key == key then return p end
    end
end

-- WoW only exposes a whole channel's level, never a single sound's.
function BFH:GetChannelVolume()
    local cvar = self.CHANNEL_CVAR[self.db.soundChannel] or "Sound_MasterVolume"
    local get = (C_CVar and C_CVar.GetCVar) or GetCVar
    return math.floor((tonumber(get(cvar)) or 1) * 100 + 0.5)
end

function BFH:SetChannelVolume(v)
    local cvar = self.CHANNEL_CVAR[self.db.soundChannel] or "Sound_MasterVolume"
    local set = (C_CVar and C_CVar.SetCVar) or SetCVar
    set(cvar, tostring(math.max(0, math.min(100, v)) / 100))
end

function BFH:PlaySoundEntry(key)
    local s = self.SOUND_BY_KEY[key]
    if not s then return end
    local channel = self.db.soundChannel or "Master"
    if s.kit then
        if SOUNDKIT and SOUNDKIT[s.kit] then PlaySound(SOUNDKIT[s.kit], channel) end
    elseif s.file then
        PlaySoundFile(self.MEDIA .. s.file, channel)
    end
end

-- Plays the sound attached to one moment of the sequence.
function BFH:PlayEvent(event)
    local key = self.sounds and self.sounds[event]
    if key and key ~= "none" then self:PlaySoundEntry(key) end
end

-- Random burning-card sound as a Putrefy card is used. A combo preset shows
-- the switch as on but covers that moment with its own sound, so it stays out.
function BFH:PlayCardBurn()
    if self.comboMode or not self.cardBurn then return end
    local list = self.CARD_BURN
    self:PlaySoundEntry(list[math.random(#list)])
end

function BFH:ApplySoundPreset(presetKey)
    if not self:GetPreset(presetKey) then return end
    self.db.soundPreset = presetKey
    self:RefreshSoundState()
end

-- Resolves the active preset into plain fields, so the sequence never has to
-- work out which sounds apply while it is running. Only Custom mode stores its
-- own picks; Majora keeps just its SFX switch and Umamusume is fixed.
function BFH:RefreshSoundState()
    local key = self.db.soundPreset or "custom"
    local preset = self:GetPreset(key) or self:GetPreset("custom")
    self.comboMode = (preset.combo and true) or false

    if key == "custom" then
        self.sounds = self.db.custom.sounds
        self.cardBurn = self.db.custom.cardBurn and true or false
    elseif self.comboMode then
        self.sounds = preset.sounds
        self.cardBurn = true
    else
        self.sounds = preset.sounds or {}
        self.cardBurn = self.db.majoraCardBurn and true or false
    end
end

-- Whether the sound pickers can be edited under the active preset.
function BFH:SoundsEditable()
    return (self.db.soundPreset or "custom") == "custom"
end

-- Whether the Putrefy SFX switch can be edited under the active preset.
function BFH:CardBurnEditable()
    return not self.comboMode
end

-- True only in Mythic Keystone dungeons and Mythic raid.
function BFH:InHardInstance()
    local _, _, difficultyID = GetInstanceInfo()
    return difficultyID == 8 or difficultyID == 16
end

function BFH:CanCelebrate()
    if not self.db.celebrationEnabled then return false end
    if self.db.celebrationOffInstances and self:InHardInstance() then return false end
    return true
end

-- Chains the combo sound after a use animation, and the finale after Putrefy.
function BFH:OnOnUseFinished(stage)
    if not self.comboMode or self.preview then return end
    self:PlayEvent(stage .. "_END")

    if stage ~= "PUTREFY" then return end
    if not self.comboOK then
        self:Debug("combo missed, no celebration")
        return
    end
    if not self:CanCelebrate() then return end

    local entry = self.SOUND_BY_KEY[self.sounds.PUTREFY_END]
    local wait = (entry and entry.dur) or 0
    self.celebrationToken = (self.celebrationToken or 0) + 1
    local token = self.celebrationToken
    C_Timer.After(wait, function()
        if BFH.celebrationToken == token then BFH:StartCelebration() end
    end)
end

-- Plays the finale sound, then its animation once the two line up.
function BFH:StartCelebration()
    self:PlaySoundEntry(self.db.celebrationSound)
    self.celebrationToken = (self.celebrationToken or 0) + 1
    local token = self.celebrationToken
    C_Timer.After(CELEBRATION_DELAY, function()
        if BFH.celebrationToken == token then BFH:ShowCelebration() end
    end)
end

-- Cancels a pending or running finale.
function BFH:StopCelebration()
    self.celebrationToken = (self.celebrationToken or 0) + 1
    self:HideCelebration()
end

-- Path of a bundled spoken-countdown file.
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

-- The chosen voice, falling back to the first one available.
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

-- Whether the player currently knows the spell.
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

-- Re-reads which spells are known and drops a timer for one that is gone.
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

-- Midnight hides some combat values; they must never be compared or used as keys.
local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) and true or false
end
BFH.IsSecret = IsSecret

function BFH:Debug(...)
    if self.debug then print("|cff9f1cffBlightfall debug:|r", ...) end
end

function BFH:OnDarkTransformation()
    self:StopPreview()
    self:ClearAll()
    self.dtCastTime = GetTime()

    self.comboOK = true

    if self.hasSoulReaper then
        self:ShowStage("SOUL")
    elseif self.hasBlightfall then
        self:ShowStage("BLIGHT")
    end
end

function BFH:OnSoulReaper()
    if self.stage ~= "SOUL" then return end
    if self.phase == "LOADING" then self:MissCombo("Soul Reaper cast early") end
    self:PlayOnUse("SOUL")
    if self.hasBlightfall then
        self:ShowStage("BLIGHT")
    else
        self:ClearMain()
    end
end

-- Blightfall cast: shows a Putrefy card, or ends the run if Soul Reaper is still up.
function BFH:OnBlightfall()

    if self.stage == "SOUL" then
        self:MissCombo("Blightfall cast during Soul Reaper")
        self:ClearMain()
        return
    end
    if self.stage ~= "BLIGHT" then return end
    if self.phase == "LOADING" then self:MissCombo("Blightfall cast early") end
    self:PlayOnUse("BLIGHT")
    if self.db.showPutrefy and self.hasPutrefy then
        self:ShowPutrefy(0.5)
    else
        self:ClearMain()
    end
end

function BFH:OnPutrefy()
    if self.stage ~= "PUTREFY" then return end
    self:CastPutrefy()
end

-- Marks the run as imperfect, so no finale plays.
function BFH:MissCombo(reason)
    if not self.comboOK then return end
    self.comboOK = false
    self:Debug("combo broken:", reason)
end

-- Routes one of the player's casts into the sequence.
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

-- Nothing is set up until login, where the class is known; on anything but a
-- Death Knight the addon drops its events and does no further work.
BFH:RegisterEvent("PLAYER_LOGIN")

BFH:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then
            self:UnregisterAllEvents()
            self:SetScript("OnEvent", nil)
            SLASH_BLIGHTFALL1 = "/blightfall"
            SLASH_BLIGHTFALL2 = "/bf"
            SlashCmdList.BLIGHTFALL = function()
                print("|cff9f1cffBlightfall|r does not run on second-class classes.")
            end
            return
        end

        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_TALENT_UPDATE")
        self:RegisterEvent("SPELLS_CHANGED")
        self:RegisterEvent("TRAIT_CONFIG_UPDATED")

        local saved = type(BlightfallDB) == "table" and (tonumber(BlightfallDB.schemaVersion) or 0) or 0
        if saved < RESET_BELOW_SCHEMA then
            BlightfallDB = {}
        else
            if saved < 103 then
                if BlightfallDB.soulDelay == 6.2 then BlightfallDB.soulDelay = 9.5 end
                if BlightfallDB.blightDelay == 6.2 then BlightfallDB.blightDelay = 6.0 end
            end
            if saved < 107 then

                BlightfallDB.sounds = nil
                BlightfallDB.cardBurn = nil
                BlightfallDB.comboMode = nil
                BlightfallDB.custom = nil
                BlightfallDB.soundPreset = nil
            end
            if saved < 106 then
                BlightfallDB.cardBurn = BlightfallDB.reaperBurn
                BlightfallDB.reaperBurn = nil
            end
            if saved < 105 then
                BlightfallDB.sounds = nil
                BlightfallDB.comboMode = nil
            end
            if saved < 104 then
                local old = BlightfallDB.readySound
                if type(old) == "table"
                    and not (old.SOUL == "ready_check" and old.BLIGHT == "raid_warning") then
                    BlightfallDB.sounds = {
                        SOUL_READY = old.SOUL or "none",
                        BLIGHT_READY = old.BLIGHT or "none",
                        SOUL_END = "none",
                        BLIGHT_END = "none",
                        PUTREFY_END = "none",
                    }
                end
                BlightfallDB.readySound = nil
                BlightfallDB.soundPreset = nil
            end
        end
        CopyDefaults(self.defaults, BlightfallDB)
        BlightfallDB.schemaVersion = self.SCHEMA
        self.db = BlightfallDB

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
            elseif msg == "status" then
                print("|cff9f1cffBlightfall|r v" .. self.VERSION
                    .. " | startup: " .. (self.startupError or "ok")
                    .. " | animations: " .. (ns.AnimData and "loaded" or "MISSING"))
            else
                self:ToggleConfig()
            end
        end

        local function Step(name, fn)
            if type(fn) ~= "function" then return end
            local ok, err = pcall(fn, self)
            if not ok then
                self.startupError = name .. ": " .. tostring(err)
                print("|cffff4040Blightfall|r failed during " .. name .. ": " .. tostring(err))
            end
        end

        Step("sound setup", self.RefreshSoundState)
        Step("shared media", RegisterSharedMedia)
        Step("display", self.InitializeDisplay)
        Step("minimap button", self.InitializeMinimapButton)
        Step("talents", self.RefreshTalentState)

        if not self.startupError then
            print("|cff9f1cffBlightfall|r v" .. self.VERSION .. " loaded. Type |cffffffff/bf|r for settings.")
        end
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
