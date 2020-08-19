function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

local activeProjectIndex = 0
local numberOfSelectedMediaItems = reaper.CountSelectedMediaItems(activeProjectIndex)

local selectedMediaItems = {}

for i = 0, numberOfSelectedMediaItems-1 do
  selectedMediaItems[i] = reaper.GetSelectedMediaItem(activeProjectIndex, i);
end


for i = 0, numberOfSelectedMediaItems-1 do

  if i % 2 == 0 then
    reaper.SetMediaItemSelected(selectedMediaItems[i], 1);
  else
    reaper.SetMediaItemSelected(selectedMediaItems[i], 0);
  end
end

reaper.UpdateArrange();
