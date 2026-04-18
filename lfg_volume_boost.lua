-- Create the main frame to listen for LFG events
local f = CreateFrame("Frame")

-- Set the event we want to listen to
f:RegisterEvent("LFG_PROPOSAL_SHOW")

-- Store the original volume level so we can restore it later
local originalMasterVolume = GetCVar("Sound_MasterVolume")

-- Event handler function
f:SetScript("OnEvent", function(self, event, ...)
    if event == "LFG_PROPOSAL_SHOW" then
        -- Boost the sound to maximum
        originalMasterVolume = GetCVar("Sound_MasterVolume")
        SetCVar("Sound_MasterVolume", 1.0)

        -- Set a timer to restore the volume after 5 seconds
        C_Timer.After(4, function()
            SetCVar("Sound_MasterVolume", originalMasterVolume)
        end)
    end
end)
