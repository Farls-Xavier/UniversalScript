if not isfolder("@FarlsXavier") then
    error("Root folder '@FarlsXavier' does not exist.")
    return
else
    if not isfolder("@FarlsXavier\\Universal") then
        warn("Config folder '@FarlsXavier\\Universal' doesn't exist. Creating folder.")
        makefolder("@FarlsXavier\\Universal")
        writefile("@FarlsXavier\\Universal\\Config.ini", [[
            {
                "Name": "Universal Script"
            }
        ]])
    else
        writefile("@FarlsXavier\\Universal\\README.txt", "ESP COLOR AND FOV COLOR SOON TOO LAZY")
        if not isfile("@FarlsXavier\\Universal\\Config.ini") then
            warn("Config file '@FarlsXavier\\Universal\\Config.ini' doesn't exist. Creating file.")
            writefile("@FarlsXavier\\Universal\\Config.ini", [[
                {"Name": "Universal Script"}
            ]])
        else
           print("Finished Startup")
        end
    end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Farls-Xavier/UiLibrary/main/Library.lua"))()

local HttpService = game:GetService("HttpService")
local CanRunRestOfScript = true

local FlushableTable = {}

local JSONDecode = HttpService:JSONDecode(readfile("@FarlsXavier\\Universal\\Config.ini"))

local Window = Library:Window({
    Title = JSONDecode.Name --[["Universal Script"]],
    OnClose = function()
        for i,v in pairs(FlushableTable) do
            pcall(function()
                v:Remove()
                CanRunRestOfScript = false
            end)
        end
        Library:destroy()
    end
})

local Target = nil

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ThisFolder = Instance.new("Folder", game.Workspace)
ThisFolder.Name = "UniversalFolderDump"

--[[ ESP SETTINGS ]]--
local EspSettings = {
    TeamCheck = false
}

local TracerSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255),
    Position = "Bottom"
}

local BoxSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255)
}

local NameSettings = {
    Visible = false,
    Color = Color3.fromRGB(126, 161, 255)
}

local HighlightSettings = {
    Visible = false,
    VisibleColor = Color3.fromRGB(0, 255, 0),
    NonVisibleColor = Color3.fromRGB(255, 0, 0),
    Highlights = {}
}

--[[ AIMBOT SETTINGS ]] --
local Holding = false

local AimbotSettings = {
    Enabled = false,
    WallCheck = false,
    TeamCheck = false,
    Aimpart = "Head", -- Torso, Closest, Head
    Smoothness = 0
}

local FovSettings = {
    Visible = false,
    Enabled = false,
    Color = Color3.fromRGB(126, 161, 255),
    Size = 90
}

local Tabs = {
    ["Aim"] = Window:Tab({
        Text = "Aim",
        Icon = "rbxassetid://14966164502"
    }),

    ["Visuals"] = Window:Tab({
        Text = "Visuals",
        Icon = "rbxassetid://14966779139"
    }),

    ["Player"] = Window:Tab({
        Text = "Player",
        Icon = "rbxassetid://14958157475"
    }),

    ["Config"] = Window:Tab({
        Text = "Config",
        Icon = "rbxassetid://13850085640"
    })
}

local AimTab = {
    ["Aimbot Toggle"] = Tabs.Aim:Toggle({
        Text = "Aimbot",
        Callback = function(v)
            AimbotSettings.Enabled = v
        end
    }),

    ["Aimpart Dropdown"] = Tabs.Aim:Dropdown({
        Text = "Aimpart",
        Callback = function(v)
            AimbotSettings.Aimpart = v
        end
    }),

    ["Wall Check Toggle"] = Tabs.Aim:Toggle({
        Text = "WallCheck",
        Callback = function(v)
            AimbotSettings.WallCheck = v
        end
    }), 

    ["Team Check Toggle"] = Tabs.Aim:Toggle({
        Text = "TeamCheck",
        Callback = function(v)
            AimbotSettings.TeamCheck = v
        end
    }),

    ["Smoothness Slider"] = Tabs.Aim:Slider({
        Text = "Smoothness",
        Min = 0,
        Max = 1,
        Default = 0,
        decimals = true,
        Callback = function(v)
            AimbotSettings.Smoothness = v
        end
    }),

    ["SEPERATOR11"] = Tabs.Aim:Label({
        Text = "--------------------------------------------"
    }),

    ["Fov enabled Toggle"] = Tabs.Aim:Toggle({
        Text = "FOV Enabled",
        Callback = function(v)
            FovSettings.Enabled = v
        end
    }),

    ["Fov Toggle"] = Tabs.Aim:Toggle({
        Text = "FOV Visible",
        Callback = function(v)
            FovSettings.Visible = v
        end
    }),

    ["Fov Size Slider"] = Tabs.Aim:Slider({
        Text = "FOV Size",
        Min = 10,
        Max = 999,
        Default = 90,
        Callback = function(v)
            FovSettings.Size = v
        end
    }),
}

local VisualsTab = {
    ["Boxes Toggle"] = Tabs.Visuals:Toggle({
        Text = "Boxes",
        Callback = function(v)
            BoxSettings.Visible = v
        end
    }),

    ["Highlight Toggle"] = Tabs.Visuals:Toggle({
        Text = "Highlights",
        Callback = function(v)
            HighlightSettings.Visible = v
        end
    }),

    ["Names Toggle"] = Tabs.Visuals:Toggle({
        Text = "Names",
        Callback = function(v)
            NameSettings.Visible = v
        end
    }),

    ["Tracers Toggle"] = Tabs.Visuals:Toggle({
        Text = "Tracers",
        Callback = function(v)
            TracerSettings.Visible = v
        end
    }),

    ["SEPERATOR"] = Tabs.Visuals:Label({
        Text = "--------------------------------------------"
    }),

    ["TeamCheck Toggle"] = Tabs.Visuals:Toggle({
        Text = "Team Check",
        Callback = function(v)
            EspSettings.TeamCheck = v
        end
    })
}

local PlayerTab = {
    ["WalkSpeed Slider"] = Tabs.Player:Slider({
        Text = "WalkSpeed",
        Min = 0,
        Max = 500,
        Default = Char:WaitForChild("Humanoid", math.huge).WalkSpeed,
        Callback = function(v)
            coroutine.wrap(function()
                while task.wait() do
                    Char:WaitForChild("Humanoid", math.huge).WalkSpeed = v
                end
            end)()
        end
    }),
    
    ["JumpPower Slider"] = Tabs.Player:Slider({
        Text = "JumpPower",
        Min = 0,
        Max = 500,
        Default = game.StarterPlayer.CharacterUseJumpPower and Char:WaitForChild("Humanoid", math.huge).JumpPower or Char:WaitForChild("Humanoid", math.huge).JumpHeight,
        Callback = function(v)
            if game.StarterPlayer.CharacterUseJumpPower then
                Char:WaitForChild("Humanoid", math.huge).JumpPower = v
            else
                Char:WaitForChild("Humanoid", math.huge).JumpHeight = v
            end
        end
    })
}

local ConfigTab = {
    ["SoonLabel"] = Tabs.Config:Label({
        Text = "Soon...",
        Weight = Enum.FontWeight.Heavy
    })
}

AimTab["Aimpart Dropdown"]:Add("Head", "Head")
AimTab["Aimpart Dropdown"]:Add("Torso", "Torso")

function NotObstructing(Destination, Ignore)
    local Origin = Camera.CFrame.Position
    local CheckRay = Ray.new(Origin, Destination - Origin)
    local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, Ignore)

    return Hit == nil
end

local fov = Drawing.new("Circle")
fov.Transparency = 1
fov.Filled = false
fov.Color = FovSettings.Color

table.insert(FlushableTable, fov)

local function GetClosestPlayer()
    local maxDistance = FovSettings.Enabled and FovSettings.Size or 9999999
    local mouseLocation = UserInputService:GetMouseLocation()
    local playerCharacter = Player.Character

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player and (not AimbotSettings.TeamCheck or player.Team ~= Player.Team) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local vectorDistance = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude

                if vectorDistance < maxDistance and onScreen then
                    local aimPart = player.Character:FindFirstChild(AimbotSettings.Aimpart)
                    if aimPart then
                        local aimPartPosition = aimPart.Position
                        if not AimbotSettings.WallCheck or NotObstructing(aimPartPosition, {playerCharacter, player.Character}) then
                            Target = player
                            maxDistance = vectorDistance
                        end
                    end
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled == true then
        Holding = false
        Target = nil
    end
end)

fov.Visible = false

coroutine.wrap(function()
    local CurrentStep

    CurrentStep = RunService.RenderStepped:Connect(function()
        fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if FovSettings.Enabled == true then
            fov.Visible = FovSettings.Visible
        else
            FovSettings.Visible = false
            fov.Visible = false
        end
        fov.Radius = FovSettings.Size
        if Holding == true and AimbotSettings.Enabled == true and CanRunRestOfScript == true then
            if AimbotSettings.Smoothness > 0 then
                GetClosestPlayer()

                if Target and Target.Character and Target.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil and Target.Character.Humanoid.Health > 0  then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character[AimbotSettings.Aimpart].Position), AimbotSettings.Smoothness)
                end
            else
                GetClosestPlayer()

                if Target ~= nil and Target.Character and Target.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil and Target.Character.Humanoid.Health > 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[AimbotSettings.Aimpart].Position) 
                end
            end
        end
        task.wait(0)
    end)
end)()

local function AddBoxes(player)
    local CurrentStep

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = BoxSettings.Color
    Box.Thickness = 2
    Box.Filled = false

    table.insert(FlushableTable, Box)
    table.insert(FlushableTable, CurrentStep)

    local HeadOffset = Vector3.new(0, 0.5, 0)
    local LegOffset = Vector3.new(0, 3, 0)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") ~= nil and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            local HeadPos = Camera:WorldToViewportPoint(player.Character.Head.Position + HeadOffset)
            local LegPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position - LegOffset)

            Box.Size = Vector2.new(1500 / Vector.Z, HeadPos.Y - LegPos.Y)
            Box.Position = Vector2.new(Vector.X - Box.Size.X / 2, Vector.Y - Box.Size.Y / 2)

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Box.Visible = BoxSettings.Visible
                    else
                        Box.Visible = false
                    end
                else
                    Box.Visible = BoxSettings.Visible
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
        task.wait(.1)
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Box:Remove()
        end
    end)
end

local function AddTracer(player)
    local CurrentStep

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = TracerSettings.Color
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    table.insert(FlushableTable, Tracer)
    table.insert(FlushableTable, CurrentStep)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            if TracerSettings.Position == "Bottom" then
                Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1)
            elseif TracerSettings.Position == "Middle" then
                Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif TracerSettings.Position == "Mouse" then
                Tracer.From = Vector2.new(Mouse.X, Mouse.Y)
            end
            Tracer.To = Vector2.new(Vector.X, Vector.Y)

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Tracer.Visible = TracerSettings.Visible
                    else
                        Tracer.Visible = false
                    end
                else
                    Tracer.Visible = TracerSettings.Visible
                end
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end
        task.wait(.1)
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Tracer:Remove()
        end
    end)
end

local function AddName(player)
    local CurrentStep

    local Text = Drawing.new("Text")
    Text.Transparency = 1
    Text.Size = 14
    Text.Outline = true
    Text.Center = true
    Text.Color = NameSettings.Color
    Text.OutlineColor = Color3.fromRGB(0,0,0)
    Text.Text = player.DisplayName

    table.insert(FlushableTable, Text)
    table.insert(FlushableTable, CurrentStep)

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            Text.Position = Vector2.new(Vector.X, Vector.Y - 15)

            local Distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude

            Text.Text = player.DisplayName.."["..math.round(Distance).."]"

            if OnScreen == true then
                if EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Text.Visible = NameSettings.Visible
                    else
                        Text.Visible = false
                    end
                else
                    Text.Visible = NameSettings.Visible
                end
            else
                Text.Visible = false
            end
        else
            Text.Visible = false
        end
        task.wait(.1)
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Text:Remove()
        end
    end)
end

local function AddHighlight(player)
    local ThisHighlight = Instance.new("Highlight")
    ThisHighlight.Parent = ThisFolder
    ThisHighlight.Adornee = player.Character
    ThisHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ThisHighlight.Enabled = HighlightSettings.Visible
    ThisHighlight.Name = player.Name.."'s Highlight"

    local CurrentStep

    table.insert(FlushableTable, CurrentStep)
    table.insert(FlushableTable, ThisHighlight)
    
    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if NotObstructing(player.Character.HumanoidRootPart.Position, {Player.Character, player.Character}) then
                ThisHighlight.FillColor = HighlightSettings.VisibleColor
            else
                ThisHighlight.FillColor = HighlightSettings.NonVisibleColor
            end

            ThisHighlight.Enabled = HighlightSettings.Visible
            task.wait(.1)
        end
    end)

    player.CharacterAdded:Connect(function(_char)
        for _,v in pairs(_char:GetDescendants()) do
            if v:IsA("Highlight") then
                v:Destroy()
            end
        end
        ThisHighlight.Adornee = player.Character
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if player == plr then
            CurrentStep:Disconnect()
            CurrentStep = nil
            ThisHighlight:Destroy()
        end
    end)
end

for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= Player then
        AddBoxes(v)
        AddTracer(v)
        AddName(v)
        AddHighlight(v)
        if not v.Character then
            Window:Notification("Warning", "For "..v.DisplayName.." Highlight wont work", 5)
        end
    end
end

game.Players.PlayerAdded:Connect(function(player)
    AddBoxes(player)
    AddTracer(player)
    AddName(player)
    AddHighlight(player)
end)

warn("This is version: 1.2.6 of the universal script")
