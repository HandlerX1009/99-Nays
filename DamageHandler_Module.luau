local Module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DamageRemote = ReplicatedStorage.RemoteEvents.ToolDamageObject
local AnimalFolder = workspace.Characters

function GrabAnimals() -- Get every animal with a valid primarypart on the map
    local Animals = {}
    
    for _, Animal in pairs(AnimalFolder:GetChildren()) do
        local PrimaryPart = Animal.PrimaryPart
    
        if not PrimaryPart then
            continue
        end
    
        table.insert(Animals, Animal)
    end
    
    return Animals
end

function ReturnBestDamager() -- Find player's best damaging item and return it
    local BestDamage, BestItem = -math.huge, nil

    for _, Item in pairs(LocalPlayer.Inventory:GetChildren()) do
        local DamageStatistic = Item:GetAttribute("WeaponDamage")

        if not DamageStatistic then -- [Item] isn't a damaging item
            continue
        end

        if DamageStatistic > BestDamage then
            BestDamage, BestItem = DamageStatistic, Item
        end
    end

    return BestItem
end

function Module.DamageAllAnimals() -- Damage every animal returned
    local PlayerBestItem = ReturnBestDamager()
    
    for _, Animal in pairs(GrabAnimals()) do
        coroutine.wrap(function()
            DamageRemote:InvokeServer(
                Animal,
                PlayerBestItem,
                0,
                Animal.PrimaryPart.CFrame
            )
        end)()
    end
end

return Module
