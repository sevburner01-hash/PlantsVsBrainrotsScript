-- dupe.lua
-- A fully optimized duping script for Plants vs Brainrots

local function duplicateItem(itemId, quantity)
    -- Check if the item exists in the player's inventory
    local playerInventory = getPlayerInventory()
    if not playerInventory[itemId] or playerInventory[itemId] < quantity then
        print("Error: Not enough items in inventory.")
        return
    end

    -- Duplicate the item
    for i = 1, quantity do 5
        addItemToInventory(itemId)
    end

    print("Duplication successful!")
end

local function main()
    -- Example usage: Duplicate 10 units of item with ID 123
    duplicateItem(123, 10)
end

-- Entry point
main()
