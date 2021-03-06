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
	local actionDescription = "splitAndSortOneBarForRhythmNoteStems"
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

function lengthOfOneBar()
	return lengthOfQuarterNote() * 4
end

function lengthOfPPQInSeconds(arg)
	local numberOfPulsesPerQuarterNote = 960
	return arg*lengthOfQuarterNote()/numberOfPulsesPerQuarterNote
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

	-- local numberOfNotes = 114
	local numberOfNotes = 14
	local selectedItems = getSelectedItems()

	for i = 0, #selectedItems do

		local allItemsFromSplit = {}
		allItemsFromSplit[0] = selectedItems[i]

		for j = 0, numberOfNotes - 1 do

			if j == 0 then

				local selectedItemPosition = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_POSITION")
				local newItem = reaper.SplitMediaItem(allItemsFromSplit[j], selectedItemPosition + lengthOfOneBar())
				allItemsFromSplit[j+1] = newItem

				-- at this point:
				-- allItemsFromSplit[0] is the bar note
				-- allItemsFromSplit[1] is the rest of the item

				reaper.SetMediaItemInfo_Value(allItemsFromSplit[0], "D_LENGTH", lengthOfEighthNote())

			elseif j == 1 then

				local selectedItemPosition = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_POSITION")
				local selectedItemLength = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_LENGTH")
				local newItem = reaper.SplitMediaItem(allItemsFromSplit[j], selectedItemPosition + lengthOfEighthNote())

				-- at this point when j=1:
				-- allItemsFromSplit[1] is the first eighth note
				-- newItem is the rest of the item

				local newItemPosition = reaper.GetMediaItemInfo_Value(newItem, "D_POSITION")
				local newItem3 = reaper.SplitMediaItem(newItem, newItemPosition + lengthOfOneBar())
				allItemsFromSplit[j+1] = newItem3

				-- delete the eighth note, you only want the bar note
				local trackOfItemToBeDeleted = reaper.GetMediaItemTrack(allItemsFromSplit[j])
				reaper.DeleteTrackMediaItem(trackOfItemToBeDeleted, allItemsFromSplit[j])


				local newItemPosition = reaper.GetMediaItemInfo_Value(newItem, "D_POSITION")
				reaper.SetMediaItemInfo_Value(newItem, "D_POSITION", newItemPosition - lengthOfPPQInSeconds(j) - 2*lengthOfQuarterNote() - lengthOfEighthNote()) -- separate the notes so you can hear what they sound like alone
				reaper.SetMediaItemInfo_Value(newItem, "D_LENGTH", lengthOfEighthNote())

			else

				local selectedItemPosition = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_POSITION")
				local selectedItemLength = reaper.GetMediaItemInfo_Value(allItemsFromSplit[j], "D_LENGTH")
				local newItem = reaper.SplitMediaItem(allItemsFromSplit[j], selectedItemPosition + lengthOfEighthNote())

				-- at this point when j=1:
				-- allItemsFromSplit[1] is the first eighth note
				-- newItem is the rest of the item

				local newItemPosition = reaper.GetMediaItemInfo_Value(newItem, "D_POSITION")
				local newItem2 = reaper.SplitMediaItem(newItem, newItemPosition + lengthOfPPQInSeconds(j-1))
				
				-- at this point:
				-- newItem2 is the rest of the item
				-- newItem is just relese volume noise that should be discarded

				local trackOfNewItem = reaper.GetMediaItemTrack(newItem)
				reaper.DeleteTrackMediaItem(trackOfNewItem, newItem)


				local newItem2Position = reaper.GetMediaItemInfo_Value(newItem2, "D_POSITION")
				local newItem3 = reaper.SplitMediaItem(newItem2, newItem2Position + lengthOfOneBar())
				allItemsFromSplit[j+1] = newItem3


				-- delete the eighth note, you only want the bar note
				local trackOfItemToBeDeleted = reaper.GetMediaItemTrack(allItemsFromSplit[j])
				reaper.DeleteTrackMediaItem(trackOfItemToBeDeleted, allItemsFromSplit[j])


				-- move the items over to the left to align with the grid
				local newItem2Position = reaper.GetMediaItemInfo_Value(newItem2, "D_POSITION")
				reaper.SetMediaItemInfo_Value(newItem2, "D_POSITION", newItem2Position - lengthOfPPQInSeconds(j) - j*(2.5*lengthOfQuarterNote())) -- separate the notes so you can hear what they sound like alone
				reaper.SetMediaItemInfo_Value(newItem2, "D_LENGTH", lengthOfEighthNote())

				-- delete that last item
				if j == numberOfNotes-1 then
					local trackOfItemToBeDeleted = reaper.GetMediaItemTrack(newItem3)
					reaper.DeleteTrackMediaItem(trackOfItemToBeDeleted, newItem3)
				end
			end
		end
	end





	extendByOneHundredTwentyEighthNotes()
	reaper.UpdateArrange()

endUndoBlock()






				-- print("j: " .. j)
				-- print("position: " .. tostring(selectedItemPosition))
				-- print("length: " .. tostring(selectedItemLength))
				-- print("\n")
				-- print(lengthOfPPQInSeconds(j))
