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

function ReturnPlayerAxe() -- Find player's axe and return it
    for _, Item in pairs(LocalPlayer.Inventory:GetChildren()) do
        if string.find(Item.Name, "Axe") then
            return Item
        end
    end
end

function Module.DamageAllAnimals() -- Damage every animal returned
    local PlayerAxe = ReturnPlayerAxe()
    
    for _, Animal in pairs(GrabAnimals()) do
        coroutine.wrap(function()
            DamageRemote:InvokeServer(
                Animal,
                PlayerAxe,
                0,
                Animal.PrimaryPart.CFrame
            )
        end)()
    end
end

return Module
