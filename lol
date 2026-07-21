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

-- Variáveis para conexões do ESP
local charConnections = {}
local autoCharConnection = nil

local function clrEsp()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "esp_hl" or v.Name == "esp_name" then v:Destroy() end
    end
end

-- Limpa ESP de um alvo específico
local function clrEspFromTarget(p)
    local hl = p:FindFirstChild("esp_hl")
    if hl then hl:Destroy() end
    local r = p:FindFirstChild("Head") or p:FindFirstChild("HumanoidRootPart")
    if r then
        local b = r:FindFirstChild("esp_name")
        if b then b:Destroy() end
    end
end

-- Cria o ESP verificando o atributo "Invisible"
local function mkEsp(p)
    -- Se tiver o atributo invisível ativado, remove o ESP e cancela a criação
    if p:GetAttribute("Invisible") == true then
        clrEspFromTarget(p)
        return
    end

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

-- Configura o personagem (Cria ESP e monitora atributo)
local function setupCharEsp(char)
    mkEsp(char)
    if not charConnections[char] then
        charConnections[char] = char:GetAttributeChangedSignal("Invisible"):Connect(function()
            if espChar then mkEsp(char) else clrEspFromTarget(char) end
        end)
    end
end

tab:Toggle({ Title = "ESP - Characters", Default = false, Callback = function(v)
    espChar = v
    local charsFolder = workspace:FindFirstChild("Characters")
    
    if v then
        if charsFolder then
            -- Configura os atuais
            for _, char in ipairs(charsFolder:GetChildren()) do
                if char:FindFirstChild("Humanoid") then setupCharEsp(char) end
            end
            -- Monitora novos
            autoCharConnection = charsFolder.ChildAdded:Connect(function(newChar)
                task.wait(0.1)
                if espChar and newChar:FindFirstChild("Humanoid") then setupCharEsp(newChar) end
            end)
        end
    else
        -- Desativa monitoramento
        if autoCharConnection then
            autoCharConnection:Disconnect()
            autoCharConnection = nil
        end
        for _, conn in pairs(charConnections) do
            if conn then conn:Disconnect() end
        end
        table.clear(charConnections)
        
        if not espAll then clrEsp() end
    end
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

-- Loop reduzido agora serve apenas para o ESP - Workspace
task.spawn(function()
    while task.wait(1) do
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
        -- Verifica se não está invisível antes de travar a mira
        if v:GetAttribute("Invisible") ~= true and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
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
