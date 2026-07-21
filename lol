-- Carrega a biblioteca Luna
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()

-- Cria a Janela Principal
local Window = Luna:CreateWindow({
    Name = "Painel do Desenvolvedor",
    Subtitle = "Ferramentas de Teste",
    LogoID = "0",
    Theme = "Default",
    ShowInTaskbar = true
})

-- Cria a Aba Principal
local Tab1 = Window:CreateTab({
    Name = "Utilitários",
    Icon = "tools",
    HoverText = "Ferramentas Básicas"
})

-- Cria um Botão de Exemplo
local Button = Tab1:CreateButton({
    Name = "Imprimir Teste no F9",
    Description = "Testa se a interface está funcionando.",
    Callback = function()
        print("Botão clicado! A interface Luna está funcionando perfeitamente.")
    end
})

-- Cria um Toggle (Interruptor) de Exemplo
local Toggle = Tab1:CreateToggle({
    Name = "Modo Deus (Apenas Devs)",
    Description = "Te deixa imortal para testes.",
    CurrentValue = false,
    Callback = function(Value)
        print("Modo Deus ativado: ", Value)
    end
})

-- Variáveis para guardar as conexões (evita lag e bugs quando desligar o ESP)
local autoHighlightConnection = nil
local attributeConnections = {}

-- Função para remover o Highlight
local function removeHighlight(character)
    local existingHighlight = character:FindFirstChild("DevHighlight")
    if existingHighlight then
        existingHighlight:Destroy()
    end
end

-- Função para atualizar o Highlight com base no atributo
local function updateHighlight(character)
    -- Verifica se o personagem tem o atributo "Invisible" como true
    if character:GetAttribute("Invisible") == true then
        removeHighlight(character) -- Tira o ESP
    else
        -- Se não for invisível, adiciona o ESP (caso não tenha)
        if not character:FindFirstChild("DevHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "DevHighlight"
            highlight.FillColor = Color3.fromRGB(0, 255, 255) -- Ciano
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = character
        end
    end
end

-- Função para configurar um personagem (aplicar ESP e monitorar atributo)
local function setupCharacter(character)
    -- 1. Faz a checagem inicial
    updateHighlight(character)
    
    -- 2. Cria um olheiro para monitorar se o atributo "Invisible" mudar
    local connection = character:GetAttributeChangedSignal("Invisible"):Connect(function()
        updateHighlight(character)
    end)
    
    -- Salva a conexão na tabela usando o personagem como chave
    attributeConnections[character] = connection
end

-- Novo Toggle de ESP inteligente
local HighlightToggle = Tab1:CreateToggle({
    Name = "ESP de Personagens (Filtro Inv)",
    Description = "Destaca personagens. Ignora quem tem o atributo Invisible.",
    CurrentValue = false,
    Callback = function(Value)
        local charsFolder = workspace:FindFirstChild("Characters")
        
        if not charsFolder then
            warn("Pasta 'Characters' não encontrada no workspace!")
            return
        end

        if Value then
            -- LIGADO: Garante que a tabela de conexões está limpa
            attributeConnections = {}
            
            -- 1. Configura os personagens que já estão na pasta
            for _, char in pairs(charsFolder:GetChildren()) do
                setupCharacter(char)
            end
            
            -- 2. Monitora os novos personagens que entrarem
            autoHighlightConnection = charsFolder.ChildAdded:Connect(function(newChar)
                task.wait(0.1) -- Delay para garantir que o modelo carregou os atributos
                setupCharacter(newChar)
            end)
        else
            -- DESLIGADO: 1. Para de monitorar novos personagens
            if autoHighlightConnection then
                autoHighlightConnection:Disconnect()
                autoHighlightConnection = nil
            end
            
            -- 2. Para de monitorar as mudanças de atributos em todos os personagens
            for char, connection in pairs(attributeConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            attributeConnections = {} -- Limpa a tabela
            
            -- 3. Remove o Highlight de todos os personagens
            for _, char in pairs(charsFolder:GetChildren()) do
                removeHighlight(char)
            end
        end
    end
})
