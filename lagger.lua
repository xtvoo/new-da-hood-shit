local players = game:GetService("Players")
local chat = game:GetService("TextChatService")
local runservice = game:GetService("RunService")
local player = players.LocalPlayer
local owner_name = "Haremelito"
local local_player = player

if player.Name == owner_name then return end

local whitelist = {}
local char = player.Character or player.CharacterAdded:Wait()
local bkpk = player:WaitForChild("Backpack")
local is_looping = false
local is_voiding = false
local void_thread = nil
local target_loop = nil
local noclip_loop = nil
local target_player = nil

local fling_loop = nil
local fling_target = nil

local framework_module = {_tp_bomb_conn = nil}

local Phowg = {}
function Phowg:Chat(Message)
    self.TextChatService = chat
    self.TextChatService.TextChannels.RBXGeneral:SendAsync(Message)
end

local function CustomOffsets(x: CFrame)
    local LastPos = local_player.Character.HumanoidRootPart.CFrame
    local_player.Character.Humanoid.CameraOffset = x:ToObjectSpace(CFrame.new(LastPos.Position)).Position
    local_player.Character.HumanoidRootPart.CFrame = x
    runservice.RenderStepped:Wait()
    local_player.Character.HumanoidRootPart.CFrame = LastPos
    local_player.Character.Humanoid.CameraOffset = LastPos:ToObjectSpace(CFrame.new(LastPos.Position)).Position
end

local function BuyItem(item: string, price: number?)
    repeat task.wait()
        CustomOffsets(workspace.Ignored.Shop[item.." - $"..price].Head.CFrame * CFrame.new(0,-5,0))
        fireclickdetector(workspace.Ignored.Shop[item.." - $"..price].ClickDetector)
    until local_player.Backpack:FindFirstChild(item)
    local_player.Backpack:FindFirstChild(item).Parent = local_player.Character
end

local function buy_all_guns()
    -- List of all gun names in Da Hood (update as needed)
    local gun_list = {
        "[Glock]", "[Double-Barrel SG]", "[Revolver]", "[Shotgun]", "[AK47]", "[SMG]", "[Pistol]", "[LMG]", "[Sniper]", "[Flamethrower]", "[Silencer]", "[Rifle]", "[DrumGun]", "[TacticalShotgun]", "[RPG]", "[PepperSpray]", "[Taser]"
    }
    for _, item in pairs(workspace.Ignored.Shop:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
            local name, price = item.Name:match("^(%b[]) %- %$(%d+)$")
            if name and price then
                for _, gun in ipairs(gun_list) do
                    if name == gun then
                        for i = 1, 2 do -- Double buy
                            if not bkpk:FindFirstChild(name) and not char:FindFirstChild(name) then
                                BuyItem(name, tonumber(price))
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

local function buy_everything()
    for _, item in pairs(workspace.Ignored.Shop:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
            local name, price = item.Name:match("^(%b[]) %- %$(%d+)$")
            if name and price and name ~= "[BloxyCola]" and name ~= "[iPhone]" and name ~= "[Phone]" then
                for i = 1, 2 do -- Double buy
                    if not bkpk:FindFirstChild(name) and not char:FindFirstChild(name) then
                        BuyItem(name, tonumber(price))
                    end
                end
            end
        end
    end
end

local function anti_lag()
    for _, p in pairs(players:GetPlayers()) do
        if p.Character then
            for _, desc in pairs(p.Character:GetDescendants()) do
                if desc:IsA("Accessory") then
                    desc:Destroy()
                end
            end
        end
    end
end

local function reset_velocity()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function equip_loop()
    while is_looping do
        for _, tool in ipairs(bkpk:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = char
                task.wait(0.1)
                tool.Parent = bkpk
            end
        end
        task.wait()
    end
end

local function get_big_num()
    return math.random(999999999999999999, 9999999999999999999)
end

local function start_void()
    while is_voiding do
        if char and char:FindFirstChild("HumanoidRootPart") then
            reset_velocity()
            local hrp = char.HumanoidRootPart
            hrp.CFrame = CFrame.new(get_big_num(), get_big_num(), get_big_num())
            hrp.Anchored = false
        end
        task.wait()
    end
end

local function grab_all_parts()
    for _, part in ipairs(workspace.Ignored.ItemsDrop:GetChildren()) do
        if part.Name == "Part" and part:IsA("BasePart") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 1, 0)
                task.wait(0.2)
            end
        end
    end
end

local function auto_armour()
    local hasArmour = false
    if char and char:FindFirstChild("BodyEffects") then
        local bodyEffects = char.BodyEffects
        if bodyEffects:FindFirstChild("Armor") and bodyEffects.Armor.Value > 0 then
            hasArmour = true
        end
    end
    if not hasArmour then
        for _, item in pairs(workspace.Ignored.Shop:GetChildren()) do
            if item.Name:find("%[Armour%]") and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
                local name, price = item.Name:match("^(%b[]) %- %$(%d+)$")
                if name and price then
                    BuyItem(name, tonumber(price))
                    Phowg:Chat("Auto Armour: Bought and equipped armour.")
                    break
                end
            end
        end
    else
        Phowg:Chat("Auto Armour: Already equipped.")
    end
end

local function handle_cmd(cmd, sender)
    if sender.Name ~= owner_name and not whitelist[sender.Name] then return end

    local lowerMessage = cmd:lower()
    
    if cmd == ".lag" then
        if not is_looping then
            is_looping = true
            coroutine.wrap(equip_loop)()
        end
    elseif cmd == ".stop" then
        is_looping = false

    elseif cmd == ".void" then
        is_voiding = true
        void_thread = coroutine.create(start_void)
        coroutine.resume(void_thread)

    elseif cmd == ".bring" then
        is_voiding = false
        if char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
        if sender.Character and sender.Character:FindFirstChild("HumanoidRootPart") then
            reset_velocity()
            task.wait()
            char.HumanoidRootPart.CFrame = sender.Character.HumanoidRootPart.CFrame
        end

    elseif cmd == ".armour" or cmd == ".armor" then
        auto_armour()

    elseif cmd == ".antilag" then
        anti_lag()

    elseif cmd == ".reset" then
        is_looping = false
        is_voiding = false
        task.wait(0.5)
        char = player.Character or player.CharacterAdded:Wait()
        bkpk = player:WaitForChild("Backpack")
        anti_lag()
        is_voiding = true
        void_thread = coroutine.create(start_void)
        coroutine.resume(void_thread)

    elseif cmd == ".leave" then
        player:Kick("Leaving...")

    elseif cmd == ".grab" then
        grab_all_parts()

    elseif cmd == ".buyguns" then
        buy_all_guns()

    elseif cmd == ".buyall" then
        buy_everything()

    elseif cmd:sub(1,8) == ".target " then
        local partial = cmd:sub(9):lower()
        for _, p in pairs(players:GetPlayers()) do
            if p.Name:lower():find(partial) == 1 or p.DisplayName:lower():find(partial) == 1 then
                target_player = p
                break
            end
        end
        if not target_player then
            Phowg:Chat("No matching player found for '" .. partial .. "'")
            return
        end
        is_voiding = false
        if target_loop then target_loop:Disconnect() end
        if noclip_loop then noclip_loop:Disconnect() end

        noclip_loop = runservice.Stepped:Connect(function()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

        target_loop = runservice.Stepped:Connect(function()
            if target_player and target_player.Character and target_player.Character:FindFirstChild("HumanoidRootPart")
                and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
                reset_velocity()
                char.HumanoidRootPart.CFrame = target_player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
            end
        end)

    elseif cmd == ".untarget" then
        if target_loop then target_loop:Disconnect() end
        if noclip_loop then noclip_loop:Disconnect() end
        target_loop = nil
        noclip_loop = nil
        target_player = nil
        if not is_voiding then
            is_voiding = true
            void_thread = coroutine.create(start_void)
            coroutine.resume(void_thread)
        end

    elseif cmd:sub(1,6) == ".give " then
        local uname = cmd:sub(7):lower()
        for _, p in pairs(players:GetPlayers()) do
            if p.Name:lower():find(uname) == 1 then
                whitelist[p.Name] = true
                Phowg:Chat("Whitelisted " .. p.Name)
                return
            end
        end
        Phowg:Chat("Player not found: " .. uname)

    elseif cmd:sub(1,8) == ".remove " then
        local uname = cmd:sub(9):lower()
        for _, p in pairs(players:GetPlayers()) do
            if p.Name:lower():find(uname) == 1 then
                whitelist[p.Name] = nil
                Phowg:Chat("Removed whitelist for " .. p.Name)
                return
            end
        end
        Phowg:Chat("Player not found: " .. uname)

    elseif cmd:sub(1,7) == ".fling " then
        local partial = cmd:sub(8):lower()
        for _, p in pairs(players:GetPlayers()) do
            if p.Name:lower():find(partial) == 1 or p.DisplayName:lower():find(partial) == 1 then
                fling_target = p
                break
            end
        end
        if not fling_target then
            Phowg:Chat("No matching player found for fling '" .. partial .. "'")
            return
        end
        if fling_loop then fling_loop:Disconnect() end

        fling_loop = runservice.Stepped:Connect(function()
            if fling_target and fling_target.Character and fling_target.Character:FindFirstChild("HumanoidRootPart")
                and char and char:FindFirstChild("HumanoidRootPart") then
                local myHRP = char.HumanoidRootPart
                local targetHRP = fling_target.Character.HumanoidRootPart
                reset_velocity()
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
            else
                if fling_loop then
                    fling_loop:Disconnect()
                    fling_loop = nil
                    fling_target = nil
                end
            end
        end)
        Phowg:Chat("Flinging " .. fling_target.Name .. ". Use .stopfling to stop.")

    elseif cmd == ".flingall" then
        -- Fling all players except self and owner
        local targets = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Name ~= owner_name and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, p)
            end
        end
        if #targets == 0 then
            Phowg:Chat("No valid players to fling.")
            return
        end
        if fling_loop then fling_loop:Disconnect() end

        local idx = 1
        fling_loop = runservice.Stepped:Connect(function()
            if #targets == 0 or not char or not char:FindFirstChild("HumanoidRootPart") then
                if fling_loop then
                    fling_loop:Disconnect()
                    fling_loop = nil
                end
                return
            end
            local target = targets[idx]
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myHRP = char.HumanoidRootPart
                local targetHRP = target.Character.HumanoidRootPart
                reset_velocity()
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
            end
            idx = idx + 1
            if idx > #targets then idx = 1 end
        end)
        Phowg:Chat("Flinging all players. Use .stopfling to stop.")

    elseif cmd == ".flingrandom" then
        -- Fling a random player except self and owner
        local candidates = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Name ~= owner_name and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(candidates, p)
            end
        end
        if #candidates == 0 then
            Phowg:Chat("No valid players to fling.")
            return
        end
        fling_target = candidates[math.random(1, #candidates)]
        if fling_loop then fling_loop:Disconnect() end

        fling_loop = runservice.Stepped:Connect(function()
            if fling_target and fling_target.Character and fling_target.Character:FindFirstChild("HumanoidRootPart")
                and char and char:FindFirstChild("HumanoidRootPart") then
                local myHRP = char.HumanoidRootPart
                local targetHRP = fling_target.Character.HumanoidRootPart
                reset_velocity()
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1, 0)
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
            else
                if fling_loop then
                    fling_loop:Disconnect()
                    fling_loop = nil
                    fling_target = nil
                end
            end
        end)
        Phowg:Chat("Flinging random player: " .. fling_target.Name .. ". Use .stopfling to stop.")

    elseif lowerMessage == ".rj" then
        local TeleportService = game:GetService("TeleportService")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)

    elseif cmd == ".stopfling" then
        if fling_loop then
            fling_loop:Disconnect()
            fling_loop = nil
            fling_target = nil
            Phowg:Chat("Fling stopped.")
        end

    local function tpwheels()
    local bike = workspace.OldVehicles:FindFirstChild(player.Name.."BIKE")
    if not bike then return end
    local seatPos = bike.Seat.Position
    bike.LBWheel.CFrame = CFrame.new(seatPos)
    bike.LTWheel.CFrame = CFrame.new(seatPos)
    bike.RBWheel.CFrame = CFrame.new(seatPos)
    bike.RTWheel.CFrame = CFrame.new(seatPos)
end

elseif cmd:sub(1,5) == ".sit " then
    local partial = cmd:sub(6):lower()
    local target = nil
    for _, p in pairs(players:GetPlayers()) do
        if p.Name:lower():find(partial) == 1 or p.DisplayName:lower():find(partial) == 1 then
            target = p
            break
        end
    end
    if not target or not target.Character or not target.Character:FindFirstChild("UpperTorso") then
        Phowg:Chat("No matching player found for sit '" .. partial .. "'")
        return
    end

    local bike = workspace.OldVehicles:FindFirstChild(player.Name.."BIKE")
    if not bike or not bike:FindFirstChild("Seat") then
        Phowg:Chat("Bike not found!")
        return
    end

    bike.Seat.CFrame = target.Character.UpperTorso.CFrame
    pcall(tpwheels)
    Phowg:Chat("Attempted to bring " .. target.Name .. " with bike seat.")
        
    elseif lowerMessage:sub(1,6) == ".nuke " then
        local args = {}
        for word in cmd:sub(7):gmatch("%S+") do
            table.insert(args, word)
        end
        local bomb_count = tonumber(args[1])
        local target_name_part = table.concat(args, " ", 2)
        if not bomb_count or not target_name_part then
            Phowg:Chat("wrong usage")
            return
        end
        local target_player = FindPlayer(target_name_part)
        if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("HumanoidRootPart") then
            Phowg:Chat("no plr")
            return
        end
        local local_player = LocalPlayer
        local runservice = RunService
        local function CustomOffsets(x)
            local LastPos = local_player.Character.HumanoidRootPart.CFrame
            local_player.Character.Humanoid.CameraOffset = x:ToObjectSpace(CFrame.new(LastPos.Position)).Position
            local_player.Character.HumanoidRootPart.CFrame = x
            runservice.RenderStepped:Wait()
            local_player.Character.HumanoidRootPart.CFrame = LastPos
            local_player.Character.Humanoid.CameraOffset = LastPos:ToObjectSpace(CFrame.new(LastPos.Position)).Position
        end

        local function GetBombCount()
            local count = 0
            for _, v in ipairs(local_player.Backpack:GetChildren()) do
                if v.Name == "[Grenade]" then
                    count = count + 1
                end
            end
            for _, v in ipairs(local_player.Character:GetChildren()) do
                if v.Name == "[Grenade]" then
                    count = count + 1
                end
            end
            return count
        end

        local function BuyItem(item, price, count)
            count = count or 1
            while GetBombCount() < count do
                local shopItem = workspace.Ignored.Shop[item .. " - $" .. price]
                if shopItem and shopItem:FindFirstChild("Head") and shopItem:FindFirstChild("ClickDetector") then
                    CustomOffsets(shopItem.Head.CFrame * CFrame.new(0, -5, 0))
                    fireclickdetector(shopItem.ClickDetector)
                else
                    break
                end
                task.wait()
            end
        end
        bomb_count = math.min(11, bomb_count)
        BuyItem("[Grenade]", 765, bomb_count)
        if framework_module._tp_bomb_conn then
            framework_module._tp_bomb_conn:Disconnect()
            framework_module._tp_bomb_conn = nil
        end
        framework_module._tp_bomb_conn = runservice.Heartbeat:Connect(function()
            pcall(function()
                for _, v in ipairs(workspace.Ignored:GetChildren()) do
                    if v.Name == "Handle" or (v.Name == "Part" and not v.Anchored) then
                        v.Velocity = Vector3.new(0,50,0)
                        v.CanCollide = false
                        local char = target_player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("UpperTorso") and char:FindFirstChildOfClass("Humanoid") then
                            local pos = char.UpperTorso.Position + (char.Humanoid.MoveDirection * 0.5 * char.Humanoid.WalkSpeed)
                            if (v.Position - char.HumanoidRootPart.Position).Magnitude < 30 then
                                local bp = v:FindFirstChildWhichIsA("BodyPosition")
                                if bp then bp:Destroy() end
                                v.CFrame = CFrame.new(pos)
                            else
                                local bp = v:FindFirstChildWhichIsA("BodyPosition")
                                if not bp then
                                    bp = Instance.new("BodyPosition")
                                    bp.Parent = v
                                end
                                bp.MaxForce = Vector3.new(1e9,1e9,1e9)
                                bp.Position = pos
                                bp.P = 10000
                                bp.D = 175
                            end
                        end
                    end
                end
            end)
        end)
    end
end

local function KO(v)
    if v.Character and v.Character:FindFirstChild("BodyEffects") then
        return v.Character.BodyEffects:FindFirstChild("K.O")
    end
end

local function setup_anti_stomp()
    local ko = KO(player)
    if not ko then return end
    local debounce = false
    ko.Changed:Connect(function(val)
        if val == true and not debounce then
            debounce = true
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Teleport far away to avoid stomp
                char.HumanoidRootPart.CFrame = CFrame.new(get_big_num(), get_big_num(), get_big_num())
                char.HumanoidRootPart.Anchored = true
            end
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
            task.wait(1)
            is_voiding = true
            void_thread = coroutine.create(start_void)
            coroutine.resume(void_thread)
        end
    end)
    -- Force kill if health is 0
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if char.Humanoid.Health <= 0 then
                char.Humanoid.Health = 0
                player:LoadCharacter() -- Force respawn/reset
            end
        end)
    end
    -- Reset debounce on respawn
    player.CharacterAdded:Connect(function()
        debounce = false
    end)
end

player.CharacterAdded:Connect(function(new_char)
    char = new_char
    bkpk = player:WaitForChild("Backpack")
    new_char:WaitForChild("HumanoidRootPart", 5)
    anti_lag()
    setup_anti_stomp()
end)

chat.MessageReceived:Connect(function(msg)
    if msg.TextSource then
        local sender = players:GetPlayerByUserId(msg.TextSource.UserId)
        if sender then
            local text = msg.Text:lower()
            local alias = {
                [".l"]  = ".lag",
                [".s"]  = ".stop",
                [".v"]  = ".void",
                [".b"]  = ".bring",
                [".al"] = ".antilag",
                [".r"]  = ".reset",
                [".lv"] = ".leave",
                [".q"]  = ".leave",
                [".g"]  = ".grab",
                [".bg"] = ".buyguns",
                [".ba"] = ".buyall",
                [".gv"] = ".give",
                [".rm"] = ".remove",
                [".t"]  = ".target",
                [".ut"] = ".untarget",
                [".f"]  = ".fling",
                [".sf"] = ".stopfling",
                [".n"]  = ".nuke",
                [".rj"] = ".rejoin",
                [".sit"] = ".sit",
                [".ar"] = ".armour",
                [".fa"] = ".flingall",
                [".fr"] = ".flingrandom"
            }

            local cmd_word = text:match("^%S+")
            local cmd_rest = text:sub(#cmd_word + 2)
            local final = alias[cmd_word] or cmd_word
            if cmd_rest and #cmd_rest > 0 then
                final = final .. " " .. cmd_rest
            end
            handle_cmd(final, sender)
        end
    end
end)
