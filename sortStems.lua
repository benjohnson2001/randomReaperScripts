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


-- 12 stems
-- 4 groups

-- trackIndex at 0 should have itemIndex 0
-- trackIndex at 1 should have itemIndex 12
-- trackIndex at 2 should have itemIndex 24
-- trackIndex at 3 should have itemIndex 36

-- trackIndex at 4 should have itemIndex 1
-- trackIndex at 5 should have itemIndex 13


function moveItemsToNewTracks(numberOfStems)

	local numberOfSelectedItems = getNumberOfSelectedItems()
	local stemGroup = 0
	local numberOfStemGroups = math.floor(numberOfSelectedItems/numberOfStems)

	local tracks = getArrayOfTracks()
	local items = getArrayOfItems()

	for trackIndex = 0, #tracks do

		local itemIndex = stemGroup + (trackIndex%numberOfStemGroups)*numberOfStems

--		print("stemGroup: " .. stemGroup .. " trackIndex: " .. trackIndex .. " itemIndex: " .. itemIndex .. "   ***    " .. (trackIndex%numberOfStems))

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


	-- print("GetNumTracks: ".. reaper.GetNumTracks())
	-- print("numberOfStemGroups: ".. numberOfStemGroups)
	-- print("numberOfSelectedItems: ".. numberOfSelectedItems)

	for trackIndex = 1, #tracks+1 do

			-- print(trackIndex)

		if (trackIndex % numberOfStemGroups == 0) then

			-- print("bam")
			local wantTrackDefaults = true
			trackIndexOffset = trackIndexOffset + 1
			reaper.InsertTrackAtIndex(trackIndex + trackIndexOffset, wantTrackDefaults)
			trackIndexOffset = trackIndexOffset + 1
			reaper.InsertTrackAtIndex(trackIndex + trackIndexOffset, wantTrackDefaults)
			--print(trackIndex + trackIndexOffset)
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

-- reaper.GetMediaItem_Track(selectedItem)
-- reaper.MoveMediaItemToTrack(firstItem, fifthTrack)


endUndoBlock()