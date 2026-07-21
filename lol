local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local win = lib:CreateWindow({
    Title = "azura totalmente", Icon = "swords", Author = "azurawishes silenciado teste?",
    Folder = "MeuHubESP", Size = UDim2.fromOffset(580, 460), Transparent = true, Theme = "Dark",
})

local tab = win:Tab({ Title = "Combat & Visuals", Icon = "eye", Locked = false })

local espChar, espAll = false, false
getgenv().hookAimbot = false
getgenv().camLock = false
getgenv().showFov = true
getgenv().fovSize = 150
getgenv().aimSmooth = 0.5

local plyrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = plyrs.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = lp:GetMouse()

local function clrEsp()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "esp_hl" or v.Name == "esp_name" then v:Destroy() end
    end
end

tab:Toggle({ Title = "ESP - Characters", Default = false, Callback = function(v)
    espChar = v; if not v and not espAll then clrEsp() end
end})

tab:Toggle({ Title = "ESP - Workspace", Default = false, Callback = function(v)
    espAll = v; if not v and not espChar then clrEsp() end
end})

tab:Toggle({ Title = "broken", Default = false, Callback = function(v) getgenv().hookAimbot = v end})
tab:Toggle({ Title = "head", Default = false, Callback = function(v) getgenv().camLock = v end})
tab:Toggle({ Title = "bola", Default = true, Callback = function(v) getgenv().showFov = v end})
tab:Slider({ Title = "tamanho bolna", Step = 1, Value = { Min = 50, Max = 600, Default = 150 }, Callback = function(v) getgenv().fovSize = v end})
tab:Slider({ Title = "Suavidade da Câmera (Aim)", Step = 0.1, Value = { Min = 0.1, Max = 1, Default = 0.5 }, Callback = function(v) getgenv().aimSmooth = v end})

tab:Select()

local function mkEsp(p)
    if not p:FindFirstChild("esp_hl") then
        local h = Instance.new("Highlight", p)
        h.Name = "esp_hl"; h.FillColor = Color3.new(1, 0, 0)
    end
    local r = p:FindFirstChild("Head") or p:FindFirstChild("HumanoidRootPart")
    if r and not r:FindFirstChild("esp_name") then
        local b = Instance.new("BillboardGui", r)
        b.Name = "esp_name"; b.Size = UDim2.new(0, 200, 0, 50); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0, 2, 0)
        local t = Instance.new("TextLabel", b)
        t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = p.Name; t.TextColor3 = Color3.new(1, 1, 1); t.TextScaled = true; t.TextStrokeTransparency = 0
    end
end

task.spawn(function()
    while task.wait(1) do
        if espChar then
            local f = workspace:FindFirstChild("Characters")
            if f then for _, v in ipairs(f:GetChildren()) do if v:FindFirstChild("Humanoid") then mkEsp(v) end end end
        end
        if espAll then
            local d = workspace:GetDescendants()
            for i, v in ipairs(d) do
                if v:IsA("Humanoid") and v.Parent then mkEsp(v.Parent) end
                if i % 1000 == 0 then task.wait() end
            end
        end
    end
end)

local function getClosest()
    local tgt = nil
    local dist = getgenv().fovSize 
    local list = {}
    
    for _, v in ipairs(plyrs:GetPlayers()) do
        if v ~= lp and v.Character then table.insert(list, v.Character) end
    end
    local chars = workspace:FindFirstChild("Characters")
    if chars then for _, v in ipairs(chars:GetChildren()) do table.insert(list, v) end end

    for _, v in ipairs(list) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local hrp = v.HumanoidRootPart
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mPos = uis:GetMouseLocation()
                local d = (Vector2.new(mPos.X, mPos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if d <= dist then
                    dist = d
                    tgt = v
                end
            end
        end
    end
    return tgt
end

pcall(function()
    local fov = Drawing.new("Circle")
    fov.Visible = false; fov.Color = Color3.fromRGB(255, 255, 255); fov.Thickness = 1.5; fov.Transparency = 1; fov.NumSides = 64; fov.Filled = false

    rs.RenderStepped:Connect(function()
        if getgenv().showFov and (getgenv().hookAimbot or getgenv().camLock) then
            fov.Visible = true; fov.Radius = getgenv().fovSize; fov.Position = uis:GetMouseLocation()
        else
            fov.Visible = false
        end
        if getgenv().camLock then
            local t = getClosest()
            if t and t:FindFirstChild("Head") then
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Head.Position), getgenv().aimSmooth)
            end
        end
    end)
end)

pcall(function()
    local old
    old = hookmetamethod(game, "__index", function(self, k)
        if getgenv().hookAimbot and self == mouse and (k == "Hit" or k == "Target") then
            local t = getClosest()
            if t and t:FindFirstChild("HumanoidRootPart") then
                if k == "Hit" then return t.HumanoidRootPart.CFrame end
                if k == "Target" then return t.HumanoidRootPart end
            end
        end
        return old(self, k)
    end)
end)
