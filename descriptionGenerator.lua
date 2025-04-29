--SHAZER: made a descriptor for the instances of going into rooms, as well as the updating of said descriptors on the secondary panel
-- RAVEN: made a grammars system to increase variety in description outputs
function generateRoomDescription(width, height)
    local features = {
        "The walls are rough and uneven.",
        "The air is damp and musty.",
        "Strange markings cover the walls.",
        "Dust covers the floor.",
        "You hear dripping water in the distance.",
        "The room echoes with your footsteps.",
        "A faint breeze can be felt."
    }

    local size = width * height
    local desc = (size < 9  and getDescription("smallest")) or
                 (size < 16 and getDescription("small")) or
                 (size < 25 and getDescription("medium")) or
                 (size < 36 and getDescription("large")) or
                 getDescription("largest")

    -- DEBUG
    --print(desc)

    return desc .. " " .. features[math.random(#features)]
end

function getDescription(sz)
    local adjs = {
        smallest = {"cramped", "confined", "tiny", "claustrophobic", "suffocating"},
        small = {"small", "compact", "confined", "diminutive", "snug"},
        medium = {"medium-sized", "moderately-sized", "average-sized", "normal", "unimpressive"},
        large = {"large", "roomy", "spacious", "broad", "sizable"},
        largest = {"enourmous", "massive", "colossal", "sprawling", "vast"},
    }

    local rm = {
        smallest = {"cell", "niche", "compartment", "cleft", "nook"},
        small = {"chamber", "alcove", "recess", "hollow", "roomlet"},
        medium = {"room", "space", "node", "passage", "den"},
        large = {"hall", "grotto", "vault", "cavity", "opening"},
        largest = {"cavern", "expanse", "chasm", "abyss", "crypt"},       
    }

    local comparison = {
        smallest = {"cupboard", "closet", "coffin", "burrow", "basket"},
        small = {"hut", "booth", "shed", "room", "hallway"},
        medium = {""},
        large = {"house", "warehouse", "theater", "gymnasium", "ballroom"},
        largest = {"cathedral", "crater", "hangar", "stadium", "arena"},       
    }

    local grammars = {
        -- a(n) $ADJ $ROOM
        addArticle(adjs[sz][math.random(#adjs[sz])], true) .. 
            " " .. rm[sz][math.random(#rm[sz])] .. ".",
        -- a(n) $ROOM more $ADJ than a(n) $COMPARISON
        addArticle(rm[sz][math.random(#rm[sz])], true) .. " more " .. 
            adjs[sz][math.random(#adjs[sz])] .. " than " .. 
            addArticle(comparison[sz][math.random(#comparison[sz])], false) .. ".", 
        -- a(n) $ROOM almost as $ADJ as a(n) $COMPARISON
        addArticle(rm[sz][math.random(#rm[sz])], true) .. " almost as " .. 
            adjs[sz][math.random(#adjs[sz])] .. " as " .. 
            addArticle(comparison[sz][math.random(#comparison[sz])], false) .. ".", 
    } 

    if sz == "medium" then return grammars[1]
    else return grammars[math.random(#grammars)] end
end

function addArticle(s, caps)
    local article = ""
    if caps == true then article = "A"
    else article = "a" end

    if isVowel(string.sub(s, 1, 1)) then article = article .. "n" end

    return article .. " " .. s
end

function isVowel(c)
    if c == "a" then return true end
    if c == "e" then return true end
    if c == "i" then return true end
    if c == "o" then return true end
    if c == "u" then return true end
    return false
end

function addStateVerb(s)
    local v = ""
    if isPlural(s) then v = " are "
    else v = " is " end

    return s .. v
end

function isPlural(s)
    if s.sub(s, -1) == "s" then return true end
    return false
end