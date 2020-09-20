-- @noindex

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
	local actionDescription = "splitAndSortEighthNoteStems"
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

function getSelectedItems()

	local selectedItems = {}

	local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

	for i = 0, numberOfSelectedItems - 1 do
		selectedItems[i] = reaper.GetSelectedMediaItem(activeProjectIndex, i)
	end

	return selectedItems

end

function extendByOneHundredTwentyEighthNotes()

	local commandId = reaper.NamedCommandLookup("_RS565b2e47b74342346d72ae0984829d80013cd1fc")
	reaper.Main_OnCommand(commandId, 0)
end



local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)

if numberOfSelectedItems == 0 then
	reaper.defer(emptyFunctionToPreventAutomaticCreationOfUndoPoint)
	return
end

startUndoBlock()

	local numberOfNotes = 129
	local selectedItems = getSelectedItems()

	for i = 0, #selectedItems do

		local allItemsFromSplit = {}
		allItemsFromSplit[0] = selectedItems[i]

		for j = 0, numberOfNotes - 1 do

			if j == 0 then

				local selectedItemPosition = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_POSITION")
				local newItem = reaper.SplitMediaItem(allItemsFromSplit[j], selectedItemPosition + lengthOfEighthNote())
				allItemsFromSplit[j+1] = newItem

			else

				local selectedItemPosition = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_POSITION")
				local newItem = reaper.SplitMediaItem(allItemsFromSplit[j], selectedItemPosition + lengthOfEighthNote())
				local newItem2 = reaper.SplitMediaItem(newItem, selectedItemPosition + lengthOfEighthNote() + j*lengthOfHundredTwentyEighthNote())
				
				allItemsFromSplit[j+1] = newItem2

				local newItem2Position = reaper.GetMediaItemInfo_Value(newItem2, "D_POSITION")

				if j == numberOfNotes - 1 then

					local newItem3 = reaper.SplitMediaItem(newItem2, newItem2Position + lengthOfEighthNote())
					local trackOfNewItem3 = reaper.GetMediaItemTrack(newItem3)
					reaper.DeleteTrackMediaItem(trackOfNewItem3, newItem3)
				end

				local trackOfNewItem = reaper.GetMediaItemTrack(newItem)
				reaper.DeleteTrackMediaItem(trackOfNewItem, newItem)

				reaper.SetMediaItemInfo_Value(newItem2, "D_POSITION", newItem2Position - j*lengthOfHundredTwentyEighthNote())
			end
		end
	end

	extendByOneHundredTwentyEighthNotes()
	reaper.UpdateArrange()

endUndoBlock()
