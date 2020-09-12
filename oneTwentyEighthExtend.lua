local activeProjectIndex = 0

function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

function startUndoBlock()
	reaper.Undo_BeginBlock()
end

function endUndoBlock()
	local actionDescription = "oneTwentyEighthExtend"
	reaper.Undo_OnStateChange(actionDescription)
	reaper.Undo_EndBlock(actionDescription, -1)
end

function currentBpm()
	local timePosition = 0
	return reaper.TimeMap2_GetDividedBpmAtTime(activeProjectIndex, timePosition)
end

function lengthOfOneTwentyEighthNote()

	local lengthOfQuarterNoteInSeconds = 60/currentBpm()
	local lengthOfEigthNoteInSeconds = lengthOfQuarterNoteInSeconds/2
	local lengthOfSixteenthNoteInSeconds = lengthOfEigthNoteInSeconds/2
	local lengthOfThirtySecondNoteInSeconds = lengthOfSixteenthNoteInSeconds/2
	local lengthOfSixtyFourthNoteInSeconds = lengthOfThirtySecondNoteInSeconds/2
	local lengthOfOneTwentyEighthNoteInSeconds = lengthOfSixtyFourthNoteInSeconds/2

	return lengthOfOneTwentyEighthNoteInSeconds
end


startUndoBlock()

	local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)


	for i = 0, numberOfSelectedItems - 1 do

		local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
		local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
		local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")

		reaper.SetMediaItemInfo_Value(selectedItem, "D_POSITION", selectedItemPosition-lengthOfOneTwentyEighthNote())
		reaper.SetMediaItemInfo_Value(selectedItem, "D_LENGTH", selectedItemLength + 2*lengthOfOneTwentyEighthNote())
		
		reaper.SetMediaItemInfo_Value(selectedItem, "D_FADEINLEN", lengthOfOneTwentyEighthNote())
		reaper.SetMediaItemInfo_Value(selectedItem, "D_FADEOUTLEN", lengthOfOneTwentyEighthNote())

		local fadeOutShape = 4
		reaper.SetMediaItemInfo_Value(selectedItem, "C_FADEINSHAPE", fadeOutShape)
		reaper.SetMediaItemInfo_Value(selectedItem, "C_FADEOUTSHAPE", fadeOutShape)

		--local _, gridDivision, t = reaper.GetSetProjectGrid(activeProjectIndex, false)

	end

endUndoBlock()