local Module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragRemotes = {
    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem,
    ReplicatedStorage.RemoteEvents.StopDraggingItem
}

local PlantRemote = ReplicatedStorage.RemoteEvents.RequestPlantItem
local CookRemote = ReplicatedStorage.RemoteEvents.RequestCookItem

local ItemFolder = workspace.Items
local MapFolder = workspace.Map

local Scrapper = MapFolder.Campground.Scrapper
local Fire = MapFolder.Campground.MainFire

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
    local IsUncooked = Item.Name == "Morsel" or Item.Name == "Steak"
    local IsChair = Item.Name == "Chair"
    
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
        ["IsUncooked"] = IsUncooked,
        ["IsChair"] = IsChair,
    }
    
    return ItemTypes
end

function BringItem(Item, CFrame) -- Take ownership of [Item] and move to [CFrame]
    if not Item.PrimaryPart then
        return
    end

    local BodyPos = Instance.new("BodyPosition", Item.PrimaryPart)

    BodyPos.Position = CFrame.Position
    BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyPos.P = 50000

    coroutine.wrap(function()
        DragRemotes[1]:FireServer(Item) -- Take ownership

        task.wait(.5)
    
        DragRemotes[2]:FireServer(Item) -- Release ownership

        RopeAtt:Destroy()
        Att0:Destroy()
        Att1:Destroy()
    end)()
end

function Module.GrabItems() -- Main function
    for I, Item in pairs(ItemFolder:GetChildren()) do
        if not Item:IsA("Model") then
            continue
        end

        --[[if I % 25 == 0 then -- Prevent lagging from mass teleportation
            task.wait()
        end]]
        
        local ItemTypes = DetermineItemType(Item)
        
        local SimplifiedTypes = {
            ["Grindable"] = ItemTypes["IsScrap"] or ItemTypes["IsWood"] or ItemTypes["IsGem"] or ItemTypes["IsChair"]
        }

        if ItemTypes["IsUncooked"] then
            CookRemote:FireServer(Fire, Item)
        end
    
        if SimplifiedTypes["Grindable"] then
        
            BringItem(Item, Scrapper.WorldPivot)
        
        elseif ItemTypes["IsHealing"] then
        
            BringItem(Item, CFrame.new(-34, 4, -23))

        elseif ItemTypes["IsSapling"] then

            BringItem(Item, CFrame.new(31, 1, -31))

            coroutine.wrap(function()
                PlantRemote:InvokeServer(Item, Vector3.new(31, 1, -31))
            end)()

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
