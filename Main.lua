local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Farls-Xavier/UiLibrary/main/Library.lua"))()

local Target = nil

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

local Window = Library:Window({Title = "Universal Script"})
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

    --[[ ["Wall Check Toggle"] = Tabs.Aim:Toggle({
        Text = "WallCheck",
        Callback = function(v)
            AimbotSettings.WallCheck = v
        end
    }), ]]

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
            Char:WaitForChild("Humanoid", math.huge).WalkSpeed = v
        end
    }),
    
    ["JumpPower Slider"] = Tabs.Player:Slider({
        Text = "JumpPower",
        Min = 0,
        Max = 500,
        Default = Char:WaitForChild("Humanoid", math.huge).JumpPower or Char:WaitForChild("Humanoid", math.huge).JumpHeight,
        Callback = function(v)
            Char:WaitForChild("Humanoid", math.huge).JumpPower = v
            pcall(function()
                Char:WaitForChild("Humanoid", math.huge).JumpHeight = v
            end)
        end
    })
}

local ConfigTab = {
    ["SoonLabel"] = Tabs.Config:Label({
        Text = "Soon...",
        Weight = Enum.FontWeight.Heavy
    })
}

local fov = Drawing.new("Circle")
fov.Transparency = 1
fov.Filled = false
fov.Color = FovSettings.Color

local function GetClosestPlayer()
    local MaxDistance
    if FovSettings.Enabled == true then 
        MaxDistance = FovSettings.Size
    else
        MaxDistance = math.huge
        coroutine.wrap(function()
            wait(20); MaxDistance = math.huge
  	    end)()
    end

    for i,v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and Target == nil then
            if AimbotSettings.TeamCheck == true then
                if v.Team ~= Player.Team then
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health > 0 then
                                local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                                local part1, part2 = v.Character:FindFirstChild("HumanoidRootPart"), Player.Character:FindFirstChild("HumanoidRootPart")
                                local Distance = (part1.Postion - part2.Position).Magnitude

                                if VectorDistance < MaxDistance and OnScreen == true and not Distance >= 1000 then
                                    Target = v
                                    if AimbotSettings.Aimpart == "Closest" then
                                        --AimbotSettings.Aimpart = GetClosestBodyPart(v)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                if v.Character ~= nil then
					if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
						if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
							local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
							local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
							
                            local part1, part2 = v.Character:FindFirstChild("HumanoidRootPart"), Player.Character:FindFirstChild("HumanoidRootPart")
                            local Distance = (part1.Postion - part2.Position).Magnitude

							if VectorDistance < MaxDistance and OnScreen == true and not Distance >= 1000 then
								Target = v
                                if AimbotSettings.Aimpart == "Closest" then
                                    --AimbotSettings.Aimpart = GetClosestBodyPart(v)
                                end
							end
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
    RunService.RenderStepped:Connect(function()
        fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if FovSettings.Enabled == true then
            fov.Visible = FovSettings.Visible
        else
            FovSettings.Visible = false
            fov.Visible = false
        end
        fov.Radius = FovSettings.Size
        if Holding == true and AimbotSettings.Enabled == true then
            if AimbotSettings.Smoothness > 0 then
                local closestPlayer = GetClosestPlayer()
                if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestPlayer.Character[AimbotSettings.Aimpart].Position), AimbotSettings.Smoothness)
                end
            else
                local closestPlayer = GetClosestPlayer()
                if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(AimbotSettings.Aimpart) ~= nil then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character[AimbotSettings.Aimpart].Position)
                end
            end
        end
    end)
end)()

local function AddBoxes(player)
    local CurrentStep

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = BoxSettings.Color
    Box.Thickness = 2
    Box.Filled = false

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

    CurrentStep = RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            Text.Position = Vector2.new(Vector.X, Vector.Y - 25)

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
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            CurrentStep:Disconnect()
            CurrentStep = nil
            Text:Remove()
        end
    end)
end

for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= Player then
        AddBoxes(v)
        AddTracer(v)
        AddName(v)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    AddBoxes(player)
    AddTracer(player)
    AddName(player)
end)
