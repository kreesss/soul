local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()

local Window = Luna:CreateWindow({
	Name = "Painel do Desenvolvedor",
	Subtitle = "Ferramentas de Teste",
	LogoID = "0", 
	Theme = "Default",
	ShowInTaskbar = true
})

local Tab1 = Window:CreateTab({
	Name = "Utilitários",
	Icon = "tools",
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
