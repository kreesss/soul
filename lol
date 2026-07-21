
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()


local Window = Luna:CreateWindow({
    Name = "Painel do Desenvolvedor",
    Subtitle = "Ferramentas de Teste",
    LogoID = "5164288041", -- Coloque o ID da imagem do seu jogo aqui
    Theme = "Default",
    ShowInTaskbar = true
})

local Tab1 = Window:CreateTab({
    Name = "Utilitários",
    Icon = "5164288041",
    HoverText = "Ferramentas Básicas"
})


local Button = Tab1:CreateButton({
    Name = "Imprimir Teste no F9",
    Description = "Testa se a interface está funcionando.",
    Callback = function()
        print("Botão clicado! A interface Luna está funcionando perfeitamente.")
    end
})


local Toggle = Tab1:CreateToggle({
    Name = "Modo Deus (Apenas Devs)",
    Description = "Te deixa imortal para testes.",
    CurrentValue = false,
    Callback = function(Value)
       
        print("Modo Deus ativado: ", Value)
    end
})


local autoHighlightConnection = nil


local function applyHighlight(character)
    if not character:FindFirstChild("DevHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "DevHighlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 255) -- Cor Ciano
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Parent = character
    end
end


local HighlightToggle = Tab1:CreateToggle({
    Name = "ESP de Personagens",
    Description = "Destaca personagens atuais e os que entrarem na pasta.",
    CurrentValue = false,
    Callback = function(Value)
        local charsFolder = workspace:FindFirstChild("Characters")
        
        if not charsFolder then
            warn("Pasta 'Characters' não encontrada no workspace!")
            return
        end

        if Value then
            
            for _, char in pairs(charsFolder:GetChildren()) do
                applyHighlight(char)
            end
            
            
            autoHighlightConnection = charsFolder.ChildAdded:Connect(function(newChar)
                
                task.wait(0.1) 
                applyHighlight(newChar)
            end)
        else
          
            if autoHighlightConnection then
                autoHighlightConnection:Disconnect()
                autoHighlightConnection = nil
            end
            
          
            for _, char in pairs(charsFolder:GetChildren()) do
                local existingHighlight = char:FindFirstChild("DevHighlight")
                if existingHighlight then
                    existingHighlight:Destroy()
                end
            end
        end
    end
})
