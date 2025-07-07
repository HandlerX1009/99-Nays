local Module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DamageRemote = ReplicatedStorage.RemoteEvents.ToolDamageObject

local AnimalFolder = workspace.Characters
local FoliageFolder = workspace.Map.Foliage
local LandmarkFolder = workspace.Map.Landmarks

function GrabAnimals() -- Get every animal with a valid primarypart on the map
    local Animals = {}
    
    for _, Animal in pairs(AnimalFolder:GetChildren()) do
        local PrimaryPart = Animal.PrimaryPart
    
        if not PrimaryPart then
            return
        end
    
        table.insert(Animals, Animal)
    end
    
    return Animals
end

function GrabTrees() -- Get every tree with a valid primarypart on the map
    local Trees = {}

    function DetermineTree(Tree)
        local PrimaryPart = Tree.PrimaryPart

        if not PrimaryPart then
            continue
        end

        if string.find(Tree.Name, "Tree") then
            table.insert(Trees, Tree)
        end
    end

    for _, Tree in pairs(FoliageFolder:GetChildren()) do
        DetermineTree(Tree)
    end
    for _, Tree in pairs(LandmarkFolder:GetChildren()) do
        DetermineTree(Tree)
    end

    return Trees
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

function ReturnPlayerAxe() -- Find player's axe
    for _, Item in pairs(LocalPlayer.Inventory:GetChildren()) do
        if string.find(Item.Name, "Axe") then
            return Item
        end
    end
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

function Module.DamageAllTrees() -- Damage every tree returned
    local PlayerAxe = ReturnPlayerAxe()

    for _, Tree in pairs(GrabTrees()) do
        coroutine.wrap(function()
            DamageRemote:InvokeServer(
                Tree,
                PlayerAxe,
                0,
                Tree.PrimaryPart.CFrame
            )
        end)()
    end
end

return Module
