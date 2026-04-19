local ADDON_NAME = "LFG_Volume_Boost"
local DEFAULT_BOOST = 1.0

-- SavedVariables (declared in .toc) are injected by WoW before ADDON_LOADED.
-- LFGVolumeBoost_Global  = { BoostLevel = <number 0..1> }
-- LFGVolumeBoost_Char    = { UseCharacterSettings = <bool>, BoostLevel = <number 0..1> }

local function EnsureSettingsTables()
    if LFGVolumeBoost_Global == nil then
        LFGVolumeBoost_Global = {
            BoostLevel = DEFAULT_BOOST,
        }
    end
    if LFGVolumeBoost_Char == nil then
        LFGVolumeBoost_Char = {
            UseCharacterSettings = false,
            BoostLevel = LFGVolumeBoost_Global.BoostLevel,
        }
    end
end

local function GetSetting(key)
    EnsureSettingsTables()
    if LFGVolumeBoost_Char.UseCharacterSettings then
        return LFGVolumeBoost_Char[key]
    end
    return LFGVolumeBoost_Global[key]
end

local function SetSetting(key, value)
    EnsureSettingsTables()
    if LFGVolumeBoost_Char.UseCharacterSettings then
        LFGVolumeBoost_Char[key] = value
    else
        LFGVolumeBoost_Global[key] = value
    end
end

local function SetUseCharacterSettings(enabled)
    EnsureSettingsTables()
    if enabled and not LFGVolumeBoost_Char.UseCharacterSettings then
        -- Seed character table from current global values so the toggle is seamless.
        LFGVolumeBoost_Char.BoostLevel = LFGVolumeBoost_Global.BoostLevel
    end
    LFGVolumeBoost_Char.UseCharacterSettings = enabled
end

-- Build the Blizzard Settings panel (AddOns tab).
local function BuildSettingsPanel()
    local category = Settings.RegisterVerticalLayoutCategory("LFG Volume Boost")

    -- Checkbox: Use Character-Specific Settings
    local useCharVarTbl = { UseCharacterSettings = LFGVolumeBoost_Char.UseCharacterSettings or false }
    local useCharSetting = Settings.RegisterAddOnSetting(
        category,
        "LFGVolumeBoost_UseCharacterSettings",
        "UseCharacterSettings",
        useCharVarTbl,
        Settings.VarType.Boolean,
        "Use Character-Specific Settings",
        false
    )
    useCharSetting:SetValue(LFGVolumeBoost_Char.UseCharacterSettings or false)
    useCharSetting:SetValueChangedCallback(function(_, value)
        SetUseCharacterSettings(value)
    end)
    Settings.CreateCheckbox(
        category,
        useCharSetting,
        "If enabled, this character uses its own boost level; otherwise it follows the account-wide setting."
    )

    -- Slider: Boost Level (0..1, 5% steps)
    local boostVarTbl = { BoostLevel = GetSetting("BoostLevel") or DEFAULT_BOOST }
    local boostSetting = Settings.RegisterAddOnSetting(
        category,
        "LFGVolumeBoost_BoostLevel",
        "BoostLevel",
        boostVarTbl,
        Settings.VarType.Number,
        "Boost Level",
        DEFAULT_BOOST
    )
    boostSetting:SetValue(GetSetting("BoostLevel") or DEFAULT_BOOST)
    boostSetting:SetValueChangedCallback(function(_, value)
        SetSetting("BoostLevel", value)
    end)

    local sliderOptions = Settings.CreateSliderOptions(0, 1, 0.05)
    sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(v)
        return string.format("%d%%", math.floor(v * 100 + 0.5))
    end)
    Settings.CreateSlider(
        category,
        boostSetting,
        sliderOptions,
        "Master volume level to boost to when an LFG queue pops."
    )

    Settings.RegisterAddOnCategory(category)
end

-- Event frame
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("LFG_PROPOSAL_SHOW")

local originalMasterVolume

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        EnsureSettingsTables()
        BuildSettingsPanel()
        f:UnregisterEvent("ADDON_LOADED")
    elseif event == "LFG_PROPOSAL_SHOW" then
        originalMasterVolume = GetCVar("Sound_MasterVolume")
        local target = GetSetting("BoostLevel") or DEFAULT_BOOST
        SetCVar("Sound_MasterVolume", tostring(target))
        C_Timer.After(4, function()
            SetCVar("Sound_MasterVolume", originalMasterVolume)
        end)
    end
end)
