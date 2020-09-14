-- @noindex

local activeProjectIndex = 0

function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

function startUndoBlock()
	reaper.Undo_BeginBlock()
end

function endUndoBlock()
	local actionDescription = "sortStems"
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

function getNumberOfSelectedItems()
	return reaper.CountSelectedMediaItems(activeProjectIndex)
end

--

function getArrayOfTracks()

	local arrayOfTracks = {}

	local numberOfSelectedItems = getNumberOfSelectedItems()

	for i = 0, numberOfSelectedItems - 1 do
		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		arrayOfTracks[i] = reaper.GetMediaItem_Track(selectedItem)
	end

	return arrayOfTracks
end


function getArrayOfItems()

	local arrayOfItems = {}

	local numberOfSelectedItems = getNumberOfSelectedItems()

	for i = 0, numberOfSelectedItems - 1 do
		arrayOfItems[i] = reaper.GetSelectedMediaItem(activeProjectIndex, i)
	end

	return arrayOfItems
end

--


function alignItems(numberOfStems, noteLengthOffset)

	local numberOfSelectedItems = getNumberOfSelectedItems()
	local stemGroup = 0

	for i = 0, numberOfSelectedItems - 1 do

		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")

		reaper.SetMediaItemInfo_Value(selectedItem, "D_POSITION", selectedItemPosition-stemGroup*noteLengthOffset)

		if ((i+1) % numberOfStems == 0) then
			stemGroup = stemGroup + 1
		end
	end
end


function moveItemsToNewTracks(numberOfStems)

	local numberOfSelectedItems = getNumberOfSelectedItems()
	local stemGroup = 0
	local numberOfStemGroups = math.floor(numberOfSelectedItems/numberOfStems)

	local tracks = getArrayOfTracks()
	local items = getArrayOfItems()

	for trackIndex = 0, #tracks do

		local itemIndex = stemGroup + (trackIndex%numberOfStemGroups)*numberOfStems

		reaper.MoveMediaItemToTrack(items[itemIndex], tracks[trackIndex])

		if ((trackIndex+1) % numberOfStemGroups == 0) then
			stemGroup = stemGroup + 1
		end
	end
end


function addBufferTracks(numberOfStems)

	local tracks = getArrayOfTracks()
	local numberOfSelectedItems = getNumberOfSelectedItems()
	local numberOfStemGroups = math.floor(numberOfSelectedItems/numberOfStems)
	local trackIndexOffset = 0

	for trackIndex = 1, #tracks+1 do

		if (trackIndex % numberOfStemGroups == 0) then

			local wantTrackDefaults = true
			trackIndexOffset = trackIndexOffset + 1
			reaper.InsertTrackAtIndex(trackIndex + trackIndexOffset, wantTrackDefaults)
			trackIndexOffset = trackIndexOffset + 1
			reaper.InsertTrackAtIndex(trackIndex + trackIndexOffset, wantTrackDefaults)
		end
	end
end


function muteSelectedTracksExceptForTheFirstOne()
	local tracks = getArrayOfTracks()

	for i = 1, #tracks do
		reaper.SetMediaTrackInfo_Value(tracks[i], "B_MUTE", 1)
	end
end

function addSomeTracksAtTheEnd()

	for i = 0, 3 do
		local numberOfTracks = reaper.GetNumTracks()
		local wantTrackDefaults = true
		reaper.InsertTrackAtIndex(numberOfTracks, wantTrackDefaults)
	end
end


local numberOfStems = 12
local noteLengthOffset = lengthOfSixteenthNote()

startUndoBlock()

	alignItems(numberOfStems, noteLengthOffset)
	moveItemsToNewTracks(numberOfStems)
	addBufferTracks(numberOfStems)
	muteSelectedTracksExceptForTheFirstOne()
	addSomeTracksAtTheEnd()

endUndoBlock()