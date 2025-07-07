local Module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragRemotes = {
    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem,
    ReplicatedStorage.RemoteEvents.StopDraggingItem
}

local PlantRemote = ReplicatedStorage.RemoteEvents.RequestPlantItem

local ItemFolder = workspace.Items
local MapFolder = workspace.Map

local Scrapper = MapFolder.Campground.Scrapper

function DetermineItemType(Item) -- Determine what [Item] is a class of
    local IsScrap = Item:GetAttribute("Scrappable")
    local IsFood = Item:GetAttribute("RestoreHunger")
    local IsFuel = Item:GetAttribute("BurnFuel")
    local IsAmmo = Item:GetAttribute("RevolverAmmo") or Item:GetAttribute("RifleAmmo")
    local IsGun = Item:GetAttribute("ReloadTime")
    
    local IsWood = Item.Name == "Log"
    local IsHealing = Item.Name == "Bandage" or Item.Name == "MedKit" or Item.Name == "Cake"
    local IsGem = Item.Name == "Cultist Gem"
    local IsSapling = Item.Name == "Sapling"
    
    local ItemTypes = {
        ["IsScrap"] = IsScrap,
        ["IsHealing"] = IsHealing,
        ["IsFuel"] = IsFuel,
        ["IsFood"] = IsFood,
        ["IsWood"] = IsWood,
        ["IsGem"] = IsGem,
        ["IsAmmo"] = IsAmmo,
        ["IsSapling"] = IsSapling,
        ["IsGun"] = IsGun,
    }
    
    return ItemTypes
end

function BringItem(Item, CFrame) -- Take ownership of [Item] and move to [CFrame]
    DragRemotes[1]:FireServer(Item) -- Take ownership
    
    Item:PivotTo(CFrame)
    
    DragRemotes[2]:FireServer(Item) -- Release ownership
end

function Module.GrabItems() -- Main function
    for _, Item in pairs(ItemFolder:GetChildren()) do
        if not Item:IsA("Model") then
            continue
        end
        
        local ItemTypes = DetermineItemType(Item)
        
        local SimplifiedTypes = {
            ["Grindable"] = ItemTypes["IsScrap"] or ItemTypes["IsWood"] or ItemTypes["IsGem"]
        }
    
        if SimplifiedTypes["Grindable"] then
        
            BringItem(Item, Scrapper.WorldPivot)
        
        elseif ItemTypes["IsHealing"] then
        
            BringItem(Item, CFrame.new(-34, 4, -23))

        elseif ItemTypes["IsSapling"] then

            BringItem(Item, CFrame.new(31, 1, -31))
            PlantRemote:InvokeServer(Item, Vector3.new(31, 1, -31))

        elseif ItemTypes["IsFuel"] then
        
            BringItem(Item, CFrame.new(-34, 4, 17))
        
        elseif ItemTypes["IsFood"] then
        
            BringItem(Item, CFrame.new(-0, 4, 38))

        elseif ItemTypes["IsGun"] then

            BringItem(Item, CFrame.new(-6, 4, -23))

        elseif ItemTypes["IsAmmo"] then
        
            BringItem(Item, CFrame.new(34, 4, 44))
        
        end
    end
end

return Module
