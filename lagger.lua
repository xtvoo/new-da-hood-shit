local players = game:GetService("Players")
local chat = game:GetService("TextChatService")
local runservice = game:GetService("RunService")
local player = players.LocalPlayer
local owner_name = "CaseohIsA_StandUser"
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
    local gun_list = {
        "[Glock]", "[Double-Barrel SG]", "[Revolver]", "[Shotgun]", "[AK47]", "[SMG]", "[Pistol]", "[LMG]",
        "[Sniper]", "[Flamethrower]", "[Silencer]", "[Rifle]", "[DrumGun]", "[TacticalShotgun]", "[RPG]", "[PepperSpray]", "[Taser]"
    }
    for _, item in pairs(workspace.Ignored.Shop:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
            local name, price = item.Name:match("^(%b[]) %- %$(%d+)$")
            if name and price then
                for _, gun in ipairs(gun_list) do
                    if name == gun then
                        for i = 1, 2 do
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
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = bkpk
        end
    end
end

local function buy_everything()
    for _, item in pairs(workspace.Ignored.Shop:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
            local name, price = item.Name:match("^(%b[]) %- %$(%d+)$")
            if name and price and name ~= "[BloxyCola]" and name ~= "[iPhone]" and name ~= "[Phone]" then
                for i = 1, 2 do
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
        for _, item in pairs(bkpk:GetChildren()) do
            if item:IsA('Tool') and not string.match(item.Name:lower(), "combat") then
                item.Parent = char
                task.wait(0.1)
            end
        end

        task.wait()

        for _, item in ipairs(char:GetChildren()) do
            if item:IsA('Tool') and not string.match(item.Name:lower(), "combat") then
                item.Parent = bkpk
                task.wait(0.1)
            end
        end
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
            if (item.Name:find("%[Armour%]") or item.Name:find("%[Armor%]")) and item:FindFirstChild("ClickDetector") and item:FindFirstChild("Head") then
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
        anti_lag()
        is_voiding = true
        if void_thread then
            coroutine.resume(void_thread)
        else
            void_thread = coroutine.create(start_void)
            coroutine.resume(void_thread)
        end

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

    elseif cmd == ".mask" then
        local maskItem = "[Mask]"
        if bkpk:FindFirstChild(maskItem) then
            bkpk[maskItem].Parent = char
            Phowg:Chat("Mask equipped from backpack!")
        elseif char:FindFirstChild(maskItem) then
            Phowg:Chat("Mask is already equipped!")
        else
            Phowg:Chat("Mask not found in backpack.")
        end
    
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

                -- Stick to the target's HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 0)
                -- Apply high angular velocity to fling the target
                myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHRP.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)

                -- Also try to anchor/unanchor the target for more effect
                pcall(function()
                    targetHRP.Anchored = false
                end)
            else
                if fling_loop then
                    fling_loop:Disconnect()
                    fling_loop = nil
                    fling_target = nil
                end
            end
        end)
        Phowg:Chat("Sticking to and flinging " .. fling_target.Name .. ". Use .stopfling to stop.")

    elseif cmd == ".flingall" then
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

    elseif cmd == ".rj" then
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
        
elseif cmd:sub(1, 3) == "k! " then
    local target_name_part = message:sub(4)
    local target_player = FindPlayer(target_name_part)

    if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local local_player = LocalPlayer
    local runservice = game:GetService("RunService")
    local owner_character = OWNER.Character
    local replicated_storage = game:GetService("ReplicatedStorage")
    local main_event = replicated_storage:FindFirstChild("MainEvent")

    if not local_player.Character or not local_player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local function BuyItem(item_name, item_price, num_times)
        num_times = num_times or 1
        local full_item_name = item_name .. " - $" .. item_price
        local shop_item_path = workspace.Ignored.Shop[full_item_name]

        if not shop_item_path then
            return
        end
        local shop_item_head = shop_item_path:FindFirstChild("Head")
        local shop_item_clickdetector = shop_item_path:FindFirstChild("ClickDetector")
        if not shop_item_head or not shop_item_clickdetector then
            return
        end

        for i = 1, num_times do
            local_player.Character.HumanoidRootPart.CFrame = shop_item_head.CFrame * CFrame.new(0, -5, 0)
            fireclickdetector(shop_item_clickdetector)
            task.wait(0.1)
        end
    end

    local function GetRifle()
        local rifle = local_player.Backpack:FindFirstChild("[Rifle]")
        if rifle then return rifle end
        rifle = local_player.Character:FindFirstChild("[Rifle]")
        return rifle
    end

    local function Reload()
        local equipped_tool = local_player.Character:FindFirstChildWhichIsA("Tool")
        if equipped_tool then
            local ammo_value = equipped_tool:FindFirstChild("Ammo")
            if ammo_value and ammo_value.Value <= 0 then
                local body_effects = local_player.Character:FindFirstChild('BodyEffects')
                if body_effects then
                    local reload_effect = body_effects:FindFirstChild('Reload')
                    if reload_effect and reload_effect.Value == false then
                        main_event:FireServer("Reload", equipped_tool)
                    end
                end
            end
        end
    end

    if framework_module._killLoop then
        framework_module._killLoop:Disconnect()
        framework_module._killLoop = nil
    end

    if not GetRifle() then
        BuyItem("[Rifle]", "1694", 1)
        task.wait(0.5)
    end

    BuyItem("5 [Rifle Ammo]", "273", 5)
    task.wait(0.5)

    local rifle_tool = GetRifle()
    if rifle_tool then
        rifle_tool.Parent = local_player.Character
        task.wait(0.1)
    else
        return
    end

    framework_module._killLoop = runservice.Heartbeat:Connect(function()
        pcall(function()
            if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("HumanoidRootPart") then
                if framework_module._killLoop then
                    framework_module._killLoop:Disconnect()
                    framework_module._killLoop = nil
                end
                local ownerPlayer = FindPlayer(OWNER)
                if ownerPlayer and ownerPlayer.Character and ownerPlayer.Character:FindFirstChild("HumanoidRootPart") and BotHumanoidRootPart then
                    BotHumanoidRootPart.CFrame = ownerPlayer.Character.HumanoidRootPart.CFrame
                end
                local equipped_tool = local_player.Character:FindFirstChildWhichIsA("Tool")
                if equipped_tool and equipped_tool.Name == "[Rifle]" then
                    equipped_tool.Parent = local_player.Backpack
                end
                return
            end

            local target_ko_effect = target_player.Character:FindFirstChild("BodyEffects") and target_player.Character.BodyEffects:FindFirstChild("K.O")
            if target_ko_effect and target_ko_effect.Value == true then
                if framework_module._killLoop then
                    framework_module._killLoop:Disconnect()
                    framework_module._killLoop = nil
                end
                local ownerPlayer = FindPlayer(OWNER)
                if ownerPlayer and ownerPlayer.Character and ownerPlayer.Character:FindFirstChild("HumanoidRootPart") and BotHumanoidRootPart then
                    BotHumanoidRootPart.CFrame = ownerPlayer.Character.HumanoidRootPart.CFrame
                end
                local equipped_tool = local_player.Character:FindFirstChildWhichIsA("Tool")
                if equipped_tool and equipped_tool.Name == "[Rifle]" then
                    equipped_tool.Parent = local_player.Backpack
                end
                return
            end

            local target_hrp = target_player.Character.HumanoidRootPart
            local local_player_hrp = local_player.Character.HumanoidRootPart
            local_player_hrp.CFrame = target_hrp.CFrame * CFrame.new(0, 5, 0)

            Reload()

            local gunHandle = local_player.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Handle")
            local targetHead = target_player.Character:FindFirstChild("Head")
            local shooterPos = local_player.Character.HumanoidRootPart.Position
            local targetPos = targetHead.Position

            if gunHandle and targetHead then
                local randomOffset1 = math.random(-12, 12)
                local randomOffset2 = math.random(-12, 12)
                local randomOffset3 = math.random(-12, 12)

                main_event:FireServer(
                    "ShootGun",
                    gunHandle,
                    shooterPos - Vector3.new(randomOffset2, randomOffset1, randomOffset2),
                    targetPos - Vector3.new(randomOffset2, randomOffset2, randomOffset2),
                    targetHead,
                    Vector3.new(0, 0, -1)
                )
            end
        end)
    end)

    elseif cmd:sub(1,6) == ".nuke " then
        local args = {}
        for word in cmd:sub(7):gmatch("%S+") do
            table.insert(args, word)
        end
        local bomb_count = tonumber(args[1])
        local target_name_part = table.concat(args, " ", 2)
        if not bomb_count or not target_name_part or target_name_part == "" then
            Phowg:Chat("wrong usage: .nuke <count> <player>")
            return
        end
        local function find_player(partial)
            partial = partial:lower()
            for _, p in pairs(players:GetPlayers()) do
                if p.Name:lower():find(partial, 1, true) == 1 or (p.DisplayName and p.DisplayName:lower():find(partial, 1, true) == 1) then
                    return p
                end
            end
            return nil
        end
        local target_player = find_player(target_name_part)
        if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("HumanoidRootPart") then
            Phowg:Chat("No player found or player has no HumanoidRootPart.")
            return
        end
        bomb_count = math.min(11, bomb_count)
        -- Buy grenades as fast as possible
        local function get_bomb_count()
            local count = 0
            for _, v in ipairs(bkpk:GetChildren()) do
                if v.Name == "[Grenade]" then
                    count = count + 1
                end
            end
            for _, v in ipairs(char:GetChildren()) do
                if v.Name == "[Grenade]" then
                    count = count + 1
                end
            end
            return count
        end
        local buy_threads = {}
        while get_bomb_count() < bomb_count do
            table.insert(buy_threads, coroutine.create(function()
                BuyItem("[Grenade]", 765)
            end))
            if #buy_threads >= 4 then -- spawn up to 4 at a time for speed
                for _, co in ipairs(buy_threads) do coroutine.resume(co) end
                buy_threads = {}
            end
        end
        for _, co in ipairs(buy_threads) do coroutine.resume(co) end
        -- Wait until we have enough grenades
        while get_bomb_count() < bomb_count do task.wait(0.05) end
        -- Throw all grenades at once, sticking them to the target
        local grenades = {}
        for _, v in ipairs(bkpk:GetChildren()) do
            if v.Name == "[Grenade]" then table.insert(grenades, v) end
        end
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == "[Grenade]" then table.insert(grenades, v) end
        end
        for i = 1, bomb_count do
            local grenade = grenades[i]
            if grenade then
                grenade.Parent = char
                task.spawn(function()
                    -- Stick grenade to target
                    local target_hrp = target_player.Character and target_player.Character:FindFirstChild("HumanoidRootPart")
                    if target_hrp then
                        grenade.Handle.CFrame = target_hrp.CFrame
                        -- Weld grenade to target
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = grenade.Handle
                        weld.Part1 = target_hrp
                        weld.Parent = grenade.Handle
                    end
                    -- Equip and throw
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(grenade)
                        task.wait(0.05)
                        pcall(function() grenade:Activate() end)
                        task.wait(0.05)
                        pcall(function() grenade:Activate() end)
                    end
                end)
            end
        end
        Phowg:Chat("Nuked " .. target_player.Name .. " with " .. bomb_count .. " grenades.")
    end
end

local function KO(v)
    if v.Character and v.Character:FindFirstChild("BodyEffects") then
        return v.Character.BodyEffects:FindFirstChild("K.O")
    end
end

local function setup_anti_stomp()
    game:GetService("RunService").Stepped:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("BodyEffects") and char.BodyEffects:FindFirstChild("K.O") and char.BodyEffects["K.O"].Value == true then
            if char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState("Dead")
            end
        end
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
                [".rj"] = ".rj",
                [".sit"] = ".sit",
                [".ar"] = ".armour",
                [".fa"] = ".flingall",
                [".fr"] = ".flingrandom",
                [".mask"] = ".mask",
                ["k!"] = "k!"
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

