-- Init
local player = game.Players.LocalPlayer
local playerName = game:GetService("Players").LocalPlayer.Name
local playerHead = player.Character.Head
local tycoonNo = ""
local buttonColor = {
    decoration = Color3.fromRGB(4, 175, 236),
    essential = Color3.fromRGB(98, 37, 209),
    dropper = Color3.fromRGB(239, 184, 56),
}
--[[
Maybe clear CanBuild First
then do Focus so it add more focus and canbuild
]]
for i, v in pairs(workspace.Tycoon:GetDescendants()) do
    if v.name == "Owner" and v.value == playerName then
        tycoonNo = tostring(v.Parent)
        break
    end
end

local toggleCollect = false
local toggleCollectSound = false
local toggleBuild = false

local buildPurchased = {}
local buildFocus = {}
local buildDecor = {}
local buildCanBuild = {}

-- Functions
function AutoCollectSound()
    if not toggleCollectSound then
        game:GetService("ReplicatedStorage").Sounds.Collect:Play()
    else
        game:GetService("ReplicatedStorage").Sounds.Error:Play()
    end
    return not toggleCollectSound
end

function AutoCollectBoost()
    while task.wait(1) do
        local condition = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.LeftSide.CashBoost.Timer.Text
        if condition == "X3 CASH BOOST In Progress!" and toggleCollect then
            game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("emptyCollector"):InvokeServer()
            if not toggleCollectSound then toggleCollectSound = AutoCollectSound() end
        else
            if toggleCollectSound then toggleCollectSound = AutoCollectSound() end
        end
    end
end

function AutoBuildPurchased()
    local purchased = {}
    for i,v in pairs(workspace.Tycoon.Tycoons[tycoonNo].PurchasedObjects:GetChildren()) do
        table.insert(purchased, v.Name)
    end
    return purchased
end

function AutoBuildInit()
    buildPurchased = AutoBuildPurchased()
    buildFocus = {}
    buildDecor = {}
    buildCanBuild = {}

    -- Destroy all gamepasses
    for i, v in pairs(workspace.Tycoon.Tycoons[tycoonNo].Buttons:GetChildren()) do
        if v.Config.Gamepass.Value then
            v:Destroy()
        end
    end

    -- Add focus buttons | Add decor buttons | Set button that can be built
    for i, v in pairs(workspace.Tycoon.Tycoons[tycoonNo].Buttons:GetChildren()) do
        if not table.find(buildPurchased, v.name) and v.Glow and (v.Glow.Color == buttonColor["essential"] or v.Glow.Color == buttonColor["dropper"]) then
            table.insert(buildFocus,v.name)
        end
    end
    for i, v in pairs(workspace.Tycoon.Tycoons[tycoonNo].Buttons:GetChildren()) do
        if not table.find(buildPurchased, v.name) and not table.find(buildFocus, v.name) then
            table.insert(buildDecor,v.name)
        end
    end
    for i, v in pairs(workspace.Tycoon.Tycoons[tycoonNo].Buttons:GetChildren()) do
        if not table.find(buildPurchased, v.name) and v.Config.Owned.Value then
            table.insert(buildCanBuild,v.name)
        end
    end
end

function AutoBuildCheck(target, allowBuild)
    -- 1) Check if it's already purchased
    if table.find(buildPurchased, target) then
        local isFocus = table.find(buildFocus, target)
        if isFocus then
            table.remove(buildFocus, isFocus)
        end
        local isDecor = table.find(buildDecor, target)
        if isDecor then
            table.remove(buildFocus, isDecor)
        end
        local isCanBuild = table.find(buildCanBuild, target)
        if isCanBuild then
            table.remove(buildFocus, isCanBuild)
        end
        return
    end

    -- 2) Check if can buy button
    local isCanBuild = table.find(buildCanBuild, target)
    if isCanBuild then
        -- 3) Try to buy the button
        if workspace.Tycoon.Tycoons[tycoonNo].Buttons[target].Config.Cost.Value <= game:GetService("Players").LocalPlayer.leaderstats.Money.Value and allowBuild then
            --Build
            print("Building... " .. target)
            local button = workspace.Tycoon.Tycoons[tycoonNo].Buttons[target].Bottom
            firetouchinterest(playerHead, button, 0)
            task.wait(0.1)
            firetouchinterest(playerHead, button, 1)


            local isFocus = table.find(buildFocus, target)
            if isFocus then
                table.remove(buildFocus, isFocus)
            end
            local isDecor = table.find(buildDecor, target)
            if isDecor then
                table.remove(buildDecor, isDecor)
            end
            table.insert(buildPurchased, target)
            table.remove(buildCanBuild, isCanBuild)
            return true
        end
    else
        -- 4) Check dependency
        local requirement = tostring(workspace.Tycoon.Tycoons[tycoonNo].Buttons[target].Config.Dependency.Value)
        local isPurchased = table.find(buildPurchased,requirement)

        -- 5) If already purchased, now can build
        if isPurchased then
            table.insert(buildCanBuild, target)
            --AutoBuildCheck(target)
        else
            -- 6) If not, is it available?
            isCanBuild = table.find(buildCanBuild, requirement)
            if not isCanBuild then
                -- 7) Time to add Focus (if it's decor)
                local isFocus = table.find(buildFocus, requirement)
                if not isFocus then
                    table.insert(buildFocus, requirement)
                    table.remove(buildDecor, table.find(buildDecor, requirement))
                end
            else
                local isFocus = table.find(buildFocus, requirement)
                if not isFocus then table.insert(buildFocus, requirement) end
            end
        end
    end
    return false
end

function AutoBuildLoop()
    while task.wait(1) do
        if toggleBuild then
            -- Check Can Build
            if #buildCanBuild ~= 0 then
                print("There is can build")
                for i,v in pairs(buildCanBuild) do
                    -- Try to build focus
                    local isFocus = table.find(buildFocus, v)
                    if isFocus then
                        print("Try Focus " .. v)
                        local skip = AutoBuildCheck(v, true)
                        if skip then break end
                    else
                        if #buildFocus == 0 then
                            -- Try to build decor if no more focus
                            print("Try Decor " .. v)
                            AutoBuildCheck(v, true)
                        end
                    end
                end
            else
                print("try to build direct focus because no more can build")
                --Try to build focus
                for i,v in pairs(buildFocus) do
                    local skip = AutoBuildCheck(v, true)
                    if skip then break end
                end
            end
            print("try to build direct focus from forcing")
            --Try to build focus
            for j,k in pairs(buildFocus) do
                local skip = AutoBuildCheck(k, false)
                if skip then break end
            end
        end
    end
end

-- Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Bank Tycoon",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionFrosty"
})

OrionLib:MakeNotification({
	Name = "Done!",
	Content = "Bank Tycoon auto by me, hopefully",
	Image = "rbxassetid://4483345998",
	Time = 5
})

local Tab = Window:MakeTab({
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local cashSection = Tab:AddSection({
	Name = "Collect Cash"
})

local cashButton = Tab:AddButton({
	Name = "Manual Collect",
	Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("emptyCollector"):InvokeServer()
        game:GetService("ReplicatedStorage").Sounds.Collect:Play()
  	end
})

local cashToggle = Tab:AddToggle({
	Name = "Auto x3 Collect",
	Default = false,
	Callback = function(Value)
		toggleCollect = Value
	end
})


local buildSection = Tab:AddSection({
	Name = "Building Tycoon"
})

local buildButton = Tab:AddButton({
	Name = "Fix Build List",
	Callback = function()
        AutoBuildInit()
        game:GetService("ReplicatedStorage").Sounds.Hammer:Play()
  	end
})

local buildToggle = Tab:AddToggle({
	Name = "Auto Build",
	Default = false,
	Callback = function(Value)
		toggleBuild = Value
	end
})

local testButton = Tab:AddButton({
	Name = "Check Build Focus List",
	Callback = function()
        print("-- Build Focus List --")
        for i,v in pairs(buildFocus) do
            if i > 15 then
                break
            end
            print(v)
        end
  	end
})

local testButton = Tab:AddButton({
	Name = "Check Build Focus Last",
	Callback = function()
        print("-- Build Focus Last --")
        for i,v in pairs(buildFocus) do
            if i > #buildFocus - 15 then
                print(v)
            end
        end
  	end
})

local testButton = Tab:AddButton({
	Name = "Check Can Build List",
	Callback = function()
        print("-- Can Build List --")
        for i,v in pairs(buildCanBuild) do
            print(v)
        end
  	end
})

OrionLib:Init()

AutoBuildInit()
task.spawn(AutoCollectBoost)
task.spawn(AutoBuildLoop)