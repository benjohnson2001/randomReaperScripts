-- @noindex

local activeProjectIndex = 0

function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

function startUndoBlock()
	reaper.Undo_BeginBlock()
end

function endUndoBlock()
	local actionDescription = "decreaseMonitoringVolume"
	reaper.Undo_OnStateChange(actionDescription)
	reaper.Undo_EndBlock(actionDescription, -1)
end

function addPurestGainToMonitoringFxChainIfItDoesNotExist(masterTrack)

	local alwaysCreateANewEffect = -1
	local onlyQueryTheFirstInstanceOfTheEffect = 0
	local onlyAddAnInstanceIfEffectIsNotFound = 1
	local recFX = true

	reaper.TrackFX_AddByName(masterTrack, "PurestGain", recFX, onlyAddAnInstanceIfEffectIsNotFound)
end

startUndoBlock()

	local masterTrack = reaper.GetMasterTrack(activeProjectIndex)
	addPurestGainToMonitoringFxChainIfItDoesNotExist(masterTrack)

	local currentGainValue = reaper.TrackFX_GetParamNormalized(masterTrack, 0|0x1000000, 0)
	-- currentGainValue = string.format("%.3f", currentGainValue)

	local halfDbIncrement = 0.00625
	local numberOfHalfDbIncrements = 4

	-- print("currentGainValue: " .. currentGainValue)
	-- print("currentGainValue + halfDbIncrement: " .. currentGainValue + halfDbIncrement)

	local newGainValue = string.format("%.6f", currentGainValue - halfDbIncrement)
	reaper.TrackFX_SetParamNormalized(masterTrack, 0|0x1000000, 0, newGainValue)

endUndoBlock()