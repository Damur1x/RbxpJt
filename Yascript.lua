-- [[ ЗАВАНТАЖЕННЯ БІБЛІОТЕКИ RAYFIELD ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Yascript",
   LoadingTitle = "Ініціалізація системи...",
   LoadingSubtitle = "by Yanot",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "XenoConfigs",
      FileName = "GlobalConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   }
})

-- [[ ГЛОБАЛЬНІ СЕРВІСИ ТА ЗМІННІ ]] --
local Plrs = game:GetService("Players")
local LPlr = Plrs.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local SelectedPlayer = nil
local State = {
   Fly = false,
   Noclip = false,
   FlySpeed = 50,
   FlyMode = "Camera", -- "Camera" або "Vertical"
   Spectate = false,
   Follow = false,
   FollowDistance = 5,
   Tracers = false,
   SelectedESP = false,
   AllESP = false,
   AntiAFK = false,
   WalkSpeed = 16,
   Gravity = 196.2
}

local Colors = {
   Path = Color3.fromRGB(255, 255, 255),
   Selected = Color3.fromRGB(0, 255, 150),
   All = Color3.fromRGB(0, 255, 255)
}

-- [[ ДОПОМІЖНІ ФУНКЦІЇ ]] --
local function ApplyHighlight(char, color, name)
   if not char then return end
   local hl = char:FindFirstChild(name) or Instance.new("Highlight")
   hl.Name = name
   hl.FillColor = color
   hl.OutlineColor = Color3.new(1,1,1)
   hl.FillTransparency = 0.5
   hl.OutlineTransparency = 0
   hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
   hl.Parent = char
end

local function UpdateESP()
   for _, p in pairs(Plrs:GetPlayers()) do
      if p ~= LPlr and p.Character then
         -- Очищення старих ESP
         if p.Character:FindFirstChild("SelectedESP") then p.Character.SelectedESP:Destroy() end
         if p.Character:FindFirstChild("AllESP") then p.Character.AllESP:Destroy() end
         
         -- Накладання нових
         if State.SelectedESP and p == SelectedPlayer then
            ApplyHighlight(p.Character, Colors.Selected, "SelectedESP")
         elseif State.AllESP then
            ApplyHighlight(p.Character, Colors.All, "AllESP")
         end
      end
   end
end

-- Функція для оновлення ESP тільки для одного гравця
local function UpdatePlayerESP(p)
   if p ~= LPlr and p.Character then
      -- Очищення старих ESP
      if p.Character:FindFirstChild("SelectedESP") then p.Character.SelectedESP:Destroy() end
      if p.Character:FindFirstChild("AllESP") then p.Character.AllESP:Destroy() end
      
      -- Накладання нових
      if State.SelectedESP and p == SelectedPlayer then
         ApplyHighlight(p.Character, Colors.Selected, "SelectedESP")
      elseif State.AllESP then
         ApplyHighlight(p.Character, Colors.All, "AllESP")
      end
   end
end

-- Авто-застосування характеристик після смерті
LPlr.CharacterAdded:Connect(function(char)
    if char then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = State.WalkSpeed
        workspace.Gravity = State.Gravity
    end
end)

-- Підключення ESP оновлення для всіх гравців при респавні
for _, p in pairs(Plrs:GetPlayers()) do
    if p ~= LPlr then
        p.CharacterAdded:Connect(function(char)
            if char then
                task.wait(0.1)
                UpdatePlayerESP(p)
            end
        end)
    end
end

-- [[ ВКЛАДКА 1: ГРАВЕЦЬ ]] --
local MainTab = Window:CreateTab("🏠 Гравець", 4483362458)

MainTab:CreateSection("Характеристики")

MainTab:CreateSlider({
   Name = "Швидкість бігу",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS_Slider",
   Callback = function(V)
      State.WalkSpeed = V
      if LPlr.Character and LPlr.Character:FindFirstChild("Humanoid") then
         LPlr.Character.Humanoid.WalkSpeed = V
      end
   end,
})

MainTab:CreateSlider({
   Name = "Гравітація",
   Range = {0, 196},
   Increment = 1,
   CurrentValue = 196,
   Flag = "Grav_Slider",
   Callback = function(V)
      State.Gravity = V
      workspace.Gravity = V
   end,
})

MainTab:CreateSection("Автоматизація")

MainTab:CreateToggle({
   Name = "Anti-AFK (Анти-виліт)",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(V) State.AntiAFK = V end,
})

MainTab:CreateSection("Пересування")

local FlyToggle = MainTab:CreateToggle({
   Name = "Політ (WASD + Q/E)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(V) State.Fly = V end,
})

MainTab:CreateToggle({
   Name = "Режим: Камера (ВКЛ) / Q-E (ВИМКЛ)",
   CurrentValue = true,
   Flag = "FlyModeCam",
   Callback = function(V) State.FlyMode = V and "Camera" or "Vertical" end,
})

MainTab:CreateSlider({
   Name = "Швидкість польоту",
   Range = {10, 500},
   Increment = 5,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(V) State.FlySpeed = V end,
})

local NoclipToggle = MainTab:CreateToggle({
   Name = "Noclip (крізь стіни)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(V) State.Noclip = V end,
})

MainTab:CreateSection("Спеціальні можливості")

MainTab:CreateButton({
   Name = "Invisible (Невидимість)",
   Callback = function()
      -- Спроба 1: Прозорість (працює тільки для вас)
      local Character = LPlr.Character
      if Character then
         for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.Transparency = 1
               part.CanCollide = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
               part.Transparency = 1
            end
         end
      end
      
      -- Спроба 2: Network exploit (якщо executor підтримує)
      -- Для Synapse X та подібних executor з network функціями
      if getgenv and getgenv().setsimulationradius then
         getgenv().setsimulationradius(0)
         Rayfield:Notify({
            Title = "Invisible",
            Content = "Використано network exploit для невидимості!",
            Duration = 5
         })
      elseif sethiddenproperty then
         -- Альтернативний метод
         sethiddenproperty(LPlr, "SimulationRadius", 0)
         Rayfield:Notify({
            Title = "Invisible",
            Content = "Спроба невидимості через SimulationRadius!",
            Duration = 5
         })
      else
         Rayfield:Notify({
            Title = "Invisible",
            Content = "Застосовано прозорість. Для справжньої невидимості потрібен executor з network функціями.",
            Duration = 5
         })
      end
   end,
})

-- [[ ВКЛАДКА 2: ВЗАЄМОДІЯ ]] --
local PlayersTab = Window:CreateTab("👥 Гравці", 4483345998)

local function GetPlayerList()
   local tbl = {}
   for _, p in pairs(Plrs:GetPlayers()) do
      if p ~= LPlr and p.Parent then 
         table.insert(tbl, p.DisplayName .. " (" .. p.Name .. ")")
      end
   end
   return tbl
end

local PlayerDropdown = PlayersTab:CreateDropdown({
   Name = "ОБРАТИ ГРАВЦЯ",
   Options = GetPlayerList(),
   CurrentOption = "",
   Flag = "TargetPlayer",
   Callback = function(Option) 
      local displayText = type(Option) == "table" and Option[1] or Option
      -- Витягуємо справжнє ім'я з формату "DisplayName (Name)"
      local realName = string.match(displayText, "%((.-)%)")
      if realName then
         local player = Plrs:FindFirstChild(realName)
         if player and player.Parent then
            -- Перевіряємо, чи змінився гравець
            if SelectedPlayer ~= player then
               SelectedPlayer = player
               UpdateESP()
            end
         end
      else
         -- Якщо нічого не вибрано, очищаємо вибір
         SelectedPlayer = nil
         UpdateESP()
      end
   end,
})

-- Функція для оновлення списку гравців
local function UpdatePlayerList()
   -- Зберігаємо поточний вибраний варіант
   local currentSelection = nil
   if SelectedPlayer and SelectedPlayer.Parent then
      currentSelection = SelectedPlayer.DisplayName .. " (" .. SelectedPlayer.Name .. ")"
   end
   
   -- Оновлюємо список
   PlayerDropdown:Set(GetPlayerList())
   
   -- Якщо був вибраний гравець і він все ще в списку, встановлюємо його назад
   if currentSelection then
      local newOptions = GetPlayerList()
      for _, option in ipairs(newOptions) do
         if option == currentSelection then
            PlayerDropdown:Set(currentSelection)
            break
         end
      end
   end
end

PlayersTab:CreateButton({
   Name = "Оновити список гравців",
   Callback = function() UpdatePlayerList() end,
})

PlayersTab:CreateSection("Інструменти")

PlayersTab:CreateButton({
   Name = "Отримати інструмент вибору гравців",
   Callback = function()
      -- Перевіряємо, чи вже є інструмент
      if LPlr.Backpack:FindFirstChild("PlayerSelector") then
         LPlr.Backpack.PlayerSelector:Destroy()
         Rayfield:Notify({
            Title = "Інструмент видалено",
            Content = "Інструмент вибору гравців видалено",
            Duration = 3
         })
         return
      end
      
      -- Створюємо інструмент
      local Tool = Instance.new("Tool")
      Tool.Name = "PlayerSelector"
      Tool.ToolTip = "Натисніть на гравця, щоб обрати його"
      Tool.RequiresHandle = false
      Tool.CanBeDropped = false
      
      -- Створюємо Handle для видимості
      local Handle = Instance.new("Part")
      Handle.Name = "Handle"
      Handle.Size = Vector3.new(1, 1, 4)
      Handle.Anchored = false
      Handle.CanCollide = false
      Handle.Transparency = 0.5
      Handle.Color = Color3.fromRGB(0, 170, 255) -- Синій колір
      Handle.Material = Enum.Material.Neon
      Handle.Parent = Tool
      
      -- Додаємо Mesh для вигляду
      local Mesh = Instance.new("SpecialMesh")
      Mesh.MeshType = Enum.MeshType.Cylinder
      Mesh.Parent = Handle
      
      Tool.Parent = LPlr.Backpack
      
      -- Логіка вибору гравця
      Tool.Activated:Connect(function()
         local Mouse = LPlr:GetMouse()
         local Target = Mouse.Target
         
         if Target then
            -- Шукаємо Character від цілі
            local Character = Target:FindFirstAncestorOfClass("Model")
            if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") then
               local Player = Plrs:GetPlayerFromCharacter(Character)
               if Player and Player ~= LPlr and Player.Parent then
                  -- Обираємо гравця
                  SelectedPlayer = Player
                  UpdateESP()
                  
                  -- Оновлюємо dropdown
                  local playerName = Player.DisplayName .. " (" .. Player.Name .. ")"
                  PlayerDropdown:Set(playerName)
                  
                  Rayfield:Notify({
                     Title = "Гравець обрано",
                     Content = "Обрано: " .. playerName,
                     Duration = 3
                  })
               else
                  Rayfield:Notify({
                     Title = "Помилка",
                     Content = "Не вдалося обрати гравця",
                     Duration = 3
                  })
               end
            end
         end
      end)
      
      Rayfield:Notify({
         Title = "Інструмент отримано",
         Content = "Візьміть інструмент з інвентаря та натисніть на гравця",
         Duration = 5
      })
   end,
})

PlayersTab:CreateSection("Дії")

local SpectateToggle = PlayersTab:CreateToggle({
   Name = "Спостерігати (Camera)",
   CurrentValue = false,
   Flag = "Spectate",
   Callback = function(V) 
      State.Spectate = V
      if not V and LPlr.Character then
         workspace.CurrentCamera.CameraSubject = LPlr.Character:FindFirstChildOfClass("Humanoid")
      end
   end,
})

PlayersTab:CreateButton({
   Name = "Телепорт до нього",
   Callback = function()
      if SelectedPlayer and SelectedPlayer.Parent and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
         LPlr.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
      else
         Rayfield:Notify({Title = "Помилка", Content = "Гравець не знайдений або мертвий", Duration = 3})
      end
   end,
})

PlayersTab:CreateToggle({
   Name = "Шлях (Tracer Line)",
   CurrentValue = false,
   Flag = "Tracers",
   Callback = function(V) State.Tracers = V end,
})

local FollowToggle = PlayersTab:CreateToggle({
   Name = "Переслідувати гравця",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(V) State.Follow = V end,
})

PlayersTab:CreateSlider({
   Name = "Відстань переслідування",
   Range = {3, 20},
   Increment = 1,
   CurrentValue = 5,
   Flag = "FollowDistance",
   Callback = function(V) State.FollowDistance = V end,
})

PlayersTab:CreateToggle({
   Name = "Підсвітка обраного",
   CurrentValue = false,
   Flag = "SelectedESP",
   Callback = function(V) State.SelectedESP = V; UpdateESP() end,
})

local AllESPToggle = PlayersTab:CreateToggle({
   Name = "Підсвітити всіх",
   CurrentValue = false,
   Flag = "AllESP",
   Callback = function(V) State.AllESP = V; UpdateESP() end,
})

-- [[ ВКЛАДКА 3: НАЛАШТУВАННЯ ]] --
local SettingsTab = Window:CreateTab("⚙️ Налаштування", 7072719290)

SettingsTab:CreateSection("Бінди")

SettingsTab:CreateKeybind({
   Name = "Клавіша польоту",
   CurrentKeybind = "F",
   HoldToInteract = false,
   Callback = function()
      State.Fly = not State.Fly
      FlyToggle:Set(State.Fly)
   end,
})

SettingsTab:CreateKeybind({
   Name = "Клавіша ESP",
   CurrentKeybind = "P",
   HoldToInteract = false,
   Callback = function()
      State.AllESP = not State.AllESP
      AllESPToggle:Set(State.AllESP)
      task.wait(0.05)
      UpdateESP()
   end,
})

SettingsTab:CreateKeybind({
   Name = "Клавіша спостереження",
   CurrentKeybind = "T",
   HoldToInteract = false,
   Callback = function()
      State.Spectate = not State.Spectate
      SpectateToggle:Set(State.Spectate)
      if not State.Spectate and LPlr.Character then
         workspace.CurrentCamera.CameraSubject = LPlr.Character:FindFirstChildOfClass("Humanoid")
      end
   end,
})

SettingsTab:CreateKeybind({
   Name = "Клавіша Noclip",
   CurrentKeybind = "G",
   HoldToInteract = false,
   Callback = function()
      State.Noclip = not State.Noclip
      NoclipToggle:Set(State.Noclip)
   end,
})

SettingsTab:CreateKeybind({
   Name = "Клавіша переслідування",
   CurrentKeybind = "R",
   HoldToInteract = false,
   Callback = function()
      State.Follow = not State.Follow
      FollowToggle:Set(State.Follow)
   end,
})

SettingsTab:CreateSection("Кольори")

SettingsTab:CreateColorPicker({
   Name = "Колір шляху (Tracer)",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "PathColor",
   Callback = function(V) Colors.Path = V; UpdateESP() end,
})

SettingsTab:CreateColorPicker({
   Name = "Колір підсвітки обраного",
   Color = Color3.fromRGB(0, 255, 150),
   Flag = "SelectedColor",
   Callback = function(V) Colors.Selected = V; UpdateESP() end,
})

SettingsTab:CreateColorPicker({
   Name = "Колір підсвітки всіх",
   Color = Color3.fromRGB(0, 255, 255),
   Flag = "AllColor",
   Callback = function(V) Colors.All = V; UpdateESP() end,
})

-- [[ ЛОГІКА ТА ЦИКЛИ ]] --

-- Anti-AFK
LPlr.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Основний цикл (Fly, Tracers, Spectate)
local TracerLine = Drawing.new("Line")
TracerLine.Thickness = 2
TracerLine.Transparency = 1

RunService.RenderStepped:Connect(function()
    -- Управління гравітацією
    if State.Fly or State.Noclip then
        workspace.Gravity = 0
    else
        workspace.Gravity = State.Gravity
    end

    -- Політ
    if State.Fly and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LPlr.Character.HumanoidRootPart
        local Hum = LPlr.Character:FindFirstChildOfClass("Humanoid")
        local Cam = workspace.CurrentCamera
        local Dir = Vector3.new(0,0,0)
        
        if Hum then
            Hum:ChangeState(Enum.HumanoidStateType.Flying)
        end
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then Dir += Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then Dir -= Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then Dir -= Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then Dir += Cam.CFrame.RightVector end
        
        -- Режим керування висотою
        if State.FlyMode == "Camera" then
            -- Камера режим: літати в напрямку камери
            if UIS:IsKeyDown(Enum.KeyCode.E) then Dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then Dir -= Vector3.new(0,1,0) end
            
            if Dir.Magnitude > 0 then
                Dir = Dir.Unit
            end
            HRP.Velocity = Dir * State.FlySpeed
        else
            -- Вертикальний режим: тільки Q/E для висоти
            local HorizDir = Vector3.new(Dir.X, 0, Dir.Z)
            local VertDir = 0
            
            if UIS:IsKeyDown(Enum.KeyCode.E) then VertDir = State.FlySpeed end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then VertDir = -State.FlySpeed end
            
            if HorizDir.Magnitude > 0 then
                HorizDir = HorizDir.Unit * State.FlySpeed
            end
            HRP.Velocity = HorizDir + Vector3.new(0, VertDir, 0)
        end
    end

    -- Noclip
    if State.Noclip and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LPlr.Character.HumanoidRootPart
        local Hum = LPlr.Character:FindFirstChildOfClass("Humanoid")
        local Cam = workspace.CurrentCamera
        local Dir = Vector3.new(0,0,0)
        
        if Hum then
            Hum:ChangeState(Enum.HumanoidStateType.Flying)
        end
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then Dir += Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then Dir -= Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then Dir -= Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then Dir += Cam.CFrame.RightVector end
        
        -- Режим керування висотою для Noclip
        if State.FlyMode == "Camera" then
            -- Камера режим: літати в напрямку камери
            if UIS:IsKeyDown(Enum.KeyCode.E) then Dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then Dir -= Vector3.new(0,1,0) end
        else
            -- Вертикальний режим: тільки Q/E для висоти
            if UIS:IsKeyDown(Enum.KeyCode.E) then Dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then Dir -= Vector3.new(0,1,0) end
        end
        
        if Dir.Magnitude > 0 then
            Dir = Dir.Unit
        end
        
        -- Використовуємо CFrame для проходження крізь стіни
        HRP.CFrame = HRP.CFrame + Dir * (State.FlySpeed / 60)
        HRP.Velocity = Vector3.new(0,0,0)
        
        -- Вимикаємо колізію для всіх частин персонажа
        for _, part in pairs(LPlr.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    elseif LPlr.Character then
        -- Увімикаємо колізію назад при вимиканні Noclip
        for _, part in pairs(LPlr.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    -- Трейсери
    if State.Tracers and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local P2, OnS2 = workspace.CurrentCamera:WorldToViewportPoint(SelectedPlayer.Character.HumanoidRootPart.Position)
        
        -- Використовуємо центр нижньої частини екрана як початкову точку
        local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y * 0.8)
        
        if OnS2 then
            TracerLine.From = screenCenter
            TracerLine.To = Vector2.new(P2.X, P2.Y)
            TracerLine.Color = Colors.Path
            TracerLine.Visible = true
        else
            -- Якщо гравець поза екраном, малюємо лінію до краю екрана в напрямку гравця
            local direction = (SelectedPlayer.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
            local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, direction * 1000)
            local hit, pos = workspace:FindPartOnRay(ray, LPlr.Character)
            
            if pos then
                local edgePoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
                if onScreen then
                    TracerLine.From = screenCenter
                    TracerLine.To = Vector2.new(edgePoint.X, edgePoint.Y)
                    TracerLine.Color = Colors.Path
                    TracerLine.Visible = true
                else
                    TracerLine.Visible = false
                end
            else
                TracerLine.Visible = false
            end
        end
    else
        TracerLine.Visible = false
    end

    -- Спостереження
    if State.Spectate and SelectedPlayer and SelectedPlayer.Parent and SelectedPlayer.Character then
        local targetHum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHum and workspace.CurrentCamera.CameraSubject ~= targetHum then
            workspace.CurrentCamera.CameraSubject = targetHum
        end
    end

    -- Переслідування
    if State.Follow and SelectedPlayer and SelectedPlayer.Parent and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local myHRP = LPlr.Character.HumanoidRootPart
        local myHum = LPlr.Character:FindFirstChildOfClass("Humanoid")
        
        if myHum then
            local distance = (targetHRP.Position - myHRP.Position).Magnitude
            
            if distance > State.FollowDistance then
                -- Рухаємося до цілі
                local direction = (targetHRP.Position - myHRP.Position).Unit
                myHum:Move(direction)
            else
                -- Зупиняємося, якщо достатньо близько
                myHum:Move(Vector3.new(0, 0, 0))
            end
        end
    end
end)

-- Оновлення при зміні складу гравців
Plrs.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function(char)
        if char then
            task.wait(0.1)
            UpdatePlayerESP(p)
        end
    end)
    task.wait(0.1) -- Невелика затримка для стабільності
    UpdatePlayerList()
end)

Plrs.PlayerRemoving:Connect(function(p)
    if p == SelectedPlayer then 
        SelectedPlayer = nil 
        -- Можна додати повідомлення або автоматичне вимикання функцій
    end
    UpdateESP()
    task.wait(0.1)
    UpdatePlayerList()
end)

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "Xeno Hub", Content = "Скрипт успішно завантажено!", Duration = 5})