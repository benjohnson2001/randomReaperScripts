-- @noindex

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

local activeProjectIndex = 0

function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

function emptyFunctionToPreventAutomaticCreationOfUndoPoint()
end

function startUndoBlock()
	reaper.Undo_BeginBlock()
end

function endUndoBlock()
	local actionDescription = "renderSelectedItems"
	reaper.Undo_OnStateChange(actionDescription)
	reaper.Undo_EndBlock(actionDescription, -1)
end

function currentBpm()
	local timePosition = 0
	return reaper.TimeMap2_GetDividedBpmAtTime(activeProjectIndex, timePosition)
end

function lengthOfQuarterNote()
	return 60/currentBpm()
end

function lengthOfEighthNote()
	return lengthOfQuarterNote()/2
end

function lengthOfSixteenthNote()
	return lengthOfEighthNote()/2
end

function lengthOfThirtySecondNote()
	return lengthOfSixteenthNote()/2
end

function lengthOfSixtyFourthNote()
	return lengthOfThirtySecondNote()/2
end

function lengthOfHundredTwentyEighthNote()
	return lengthOfSixtyFourthNote()/2
end


-----

function unsoloAllTracks()

	local commandId = 40340
  reaper.Main_OnCommand(commandId, 0)
end

function soloTracksOfSelectedItems()

	local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

	for i = 0, numberOfSelectedItems - 1 do

		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		local trackOfSelectedItem = reaper.GetMediaItem_Track(selectedItem)
		reaper.SetMediaTrackInfo_Value(trackOfSelectedItem, "I_SOLO", 1)
	end
end

function maxInt()

	-- I don't know if this is actually the maximum integer value, but it's big enough
	return 2^31 - 1
end

function getStartPosition()

	local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

	local startPosition = maxInt()

	for i = 0, numberOfSelectedItems - 1 do

		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")

		if selectedItemPosition < startPosition then
			startPosition = selectedItemPosition
		end
	end

	return startPosition
end

function getEndPosition()

	local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

	local endPosition = -1

	for i = 0, numberOfSelectedItems - 1 do

		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
		local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")

		if selectedItemPosition + selectedItemLength > endPosition then
			endPosition = selectedItemPosition + selectedItemLength
		end
	end

	return endPosition
end

function setTimeSelection(startPosition, endPosition)

	local isSet = true
	local isLoop = false
	local allowAutoseek = false
	reaper.GetSet_LoopTimeRange2(activeProjectIndex, isSet, isLoop, startPosition, endPosition, allowAutoseek)
end

function getFileName()

	local numberOfInputs = 1
	local defaultFileName = ""
	local userComplied, fileName =  reaper.GetUserInputs("render selected items", numberOfInputs, "File name:,extrawidth=100", defaultFileName)
	return userComplied, fileName
end

-----


function thirtyTwoBitsFloatingPoint()
	return 3
end

function largeFilesAreAutoWavSlashWave64()
	return 0
end

function writeBwfIsCheckedAndIncludeProjectFilenameIsUnchecked()
	return 1
end

function doNotIncludeMarkersOrRegions()
	return 0
end

function doNotEmbedTempo()
	-- returning false means tempo will not be embedded
	return false
end

function currentProjectPath()
	return nil
end

function startOfTimeSelection()
	return -2
end

function endOfTimeSelection()
	return -2
end

function doNotOverwriteWithoutAsking()
	-- returning false means it will not overwrite without asking
	return false
end

function closeTheRenderWindowWhenDone()
	return true
end

function silentlyIncreaseTheFilenameIfItAlreadyExists()
	return true
end


function render(fileName)

	local outputPath = "/Users/panda/Desktop/" .. fileName .. ".wav"


	local renderConfigurationString = ultraschall.CreateRenderCFG_WAV(thirtyTwoBitsFloatingPoint(),
																																	largeFilesAreAutoWavSlashWave64(),
																																	writeBwfIsCheckedAndIncludeProjectFilenameIsUnchecked(),
																																	doNotIncludeMarkersOrRegions(),
																																	doNotEmbedTempo())

	local secondaryRenderConfigurationString = nil

	ultraschall.RenderProject(currentProjectPath(),
														outputPath,
														startOfTimeSelection(),
														endOfTimeSelection(),
														doNotOverwriteWithoutAsking(),
														closeTheRenderWindowWhenDone(),
														silentlyIncreaseTheFilenameIfItAlreadyExists(),
														renderConfigurationString,
														secondaryRenderConfigurationString)
end


----


local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

if numberOfSelectedItems == 0 then
	reaper.defer(emptyFunctionToPreventAutomaticCreationOfUndoPoint)
	return
end

startUndoBlock()

	unsoloAllTracks()
	soloTracksOfSelectedItems()

	local startPosition = getStartPosition()
	local endPosition = getEndPosition()
	setTimeSelection(startPosition, endPosition)

	local userComplied, fileName = getFileName()

	if userComplied then
		render(fileName)
	end

endUndoBlock()
