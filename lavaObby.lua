local player = game.Players.LocalPlayer
local toggle = false
count = 1

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Bank Tycoon",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionFrosty"
})

OrionLib:MakeNotification({
	Name = "Title!",
	Content = "Starto",
	Image = "rbxassetid://4483345998",
	Time = 5
})

local Tab = Window:MakeTab({
	Name = "Lava Obby",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local cashSection = Tab:AddSection({
	Name = "Lava Obby"
})

local Para = Tab:AddParagraph("Current Stage",tostring(count))

local TextBox = Tab:AddTextbox({
	Name = "Set Stage",
	TextDisappear = true,
	Callback = function(Value)
		count = tonumber(Value)
        Para:Set(tostring(count))
	end
})

local Button = Tab:AddButton({
	Name = "Go To",
	Callback = function()
        target = workspace.Plates[count].Part
        player.Character:PivotTo(CFrame.new(target.Position + Vector3.new(0, 7, 0)))
  	end
})

local Toggle = Tab:AddToggle({
	Name = "Auto Run",
	Default = false,
	Callback = function(Value)
        toggle = Value
	end
})

local Button = Tab:AddButton({
	Name = "Reset to 1",
	Callback = function()
        count = 1
  	end
})

OrionLib:Init()

while true do
    if count <= 50 and toggle then
        local checkValid = player.Character.PrimaryPart
        if not checkValid then
            task.wait(2.5)
            continue
        end

        Para:Set(tostring(count))
        target = workspace.Plates[count].Part
        player.Character:PivotTo(CFrame.new(target.Position + Vector3.new(0, 7, 0)))

        count = count + 1
    else
        Para:Set(tostring(count))
        print("Wait")
        if count > 50 then
            task.wait(5)
            count = 1
        end
    end
    task.wait(2.5)
end