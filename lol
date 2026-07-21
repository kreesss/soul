local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local win = lib:CreateWindow({
    Title = "azura totalmente", Icon = "swords", Author = "azurawishes silenciado teste?",
    Folder = "MeuHubESP", Size = UDim2.fromOffset(580, 460), Transparent = true, Theme = "Dark",
})

local tab = win:Tab({ Title = "Combat & Visuals", Icon = "eye", Locked = false })

local espChar = false
local charConnections = {}
local autoCharConnection = nil

local function clrEsp()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "esp_hl" or v.Name == "esp_name" then v:Destroy() end
    end
end

local function clrEspFromTarget(p)
    local hl = p:FindFirstChild("esp_hl")
    if hl then hl:Destroy() end
    local r = p:FindFirstChild("Head") or p:FindFirstChild("HumanoidRootPart")
    if r then
        local b = r:FindFirstChild("esp_name")
        if b then b:Destroy() end
    end
end

local function mkEsp(p)
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
            for _, char in ipairs(charsFolder:GetChildren()) do
                if char:FindFirstChild("Humanoid") then setupCharEsp(char) end
            end
            autoCharConnection = charsFolder.ChildAdded:Connect(function(newChar)
                task.wait(0.1)
                if espChar and newChar:FindFirstChild("Humanoid") then setupCharEsp(newChar) end
            end)
        end
    else
        if autoCharConnection then
            autoCharConnection:Disconnect()
            autoCharConnection = nil
        end
        for _, conn in pairs(charConnections) do
            if conn then conn:Disconnect() end
        end
        table.clear(charConnections)
        clrEsp()
    end
end})

tab:Select()
