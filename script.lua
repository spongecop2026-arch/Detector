local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local GROUP_ID = 3231454 -- Nosniy Games (Rivals developers)
local STAFF_RANK_THRESHOLD = 200 -- 200+ usually covers Mods, Admins, and Owners.
local autoKickEnabled = true

-- Clean up previous instances if executed multiple times
if CoreGui:FindFirstChild("SkibSkib_StaffDetector") then
    CoreGui.SkibSkib_StaffDetector:Destroy()
end

-- Build tiny UI
local gui = Instance.new("ScreenGui")
gui.Name = "SkibSkib_StaffDetector"
gui.ResetOnSpawn = false
gui.Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 60)
frame.Position = UDim2.new(0.5, -90, 0, -100)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 45)
stroke.Thickness = 1
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "SKIBSKIB DETECTOR"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 20)
toggleBtn.Position = UDim2.new(0.5, -70, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
toggleBtn.Text = "ACTIVE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = toggleBtn

-- Drop animation
frame:TweenPosition(UDim2.new(0.5, -90, 0, 30), "Out", "Quad", 0.4, true)

-- Core Detection Logic
local function checkStaff(player)
    if not autoKickEnabled then return end
    if player == Players.LocalPlayer then return end

    task.spawn(function()
        -- pcall this because Roblox's web API sometimes shits itself
        local success, rank = pcall(function()
            return player:GetRankInGroup(GROUP_ID)
        end)

        if success and rank >= STAFF_RANK_THRESHOLD then
            -- Formatted with newlines so it looks like a clean, official error prompt
            local kickMessage = string.format(
                "\n\n⚠️ You've been kicked by SkibSkib Mod Detections ⚠️\n\nStaff Member Joined: %s\nRank Level: %d", 
                player.Name, 
                rank
            )
            Players.LocalPlayer:Kick(kickMessage)
        end
    end)
end

-- Scan current players in case a mod is already in the server
for _, player in ipairs(Players:GetPlayers()) do
    checkStaff(player)
end

-- Listen for incoming connections
Players.PlayerAdded:Connect(checkStaff)

-- UI Toggle Logic
toggleBtn.MouseButton1Click:Connect(function()
    autoKickEnabled = not autoKickEnabled
    if autoKickEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        toggleBtn.Text = "ACTIVE"
        for _, player in ipairs(Players:GetPlayers()) do
            checkStaff(player)
        end
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleBtn.Text = "DISABLED"
    end
end)

-- Draggable Logic (Simple and effective)
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
