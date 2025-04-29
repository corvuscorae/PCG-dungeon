
function combineShortest(diff, paragraphs)
    -- print(diff)
    
    -- make a sorted version of paragraphs
    local sortedParagraphs = {};
    for i, p in ipairs(paragraphs) do
        sortedParagraphs[i] = {
            story_index = i,
            text =  p
        };
    end
    table.sort(sortedParagraphs, function(a, b)
        return #a.text < #b.text
    end)
    -- now that its sorted by length, we just want the indices
    for i, p in ipairs(sortedParagraphs) do
        sortedParagraphs[i] = sortedParagraphs[i].story_index
    end    
  
    -- find the {diff} shortest paragraphs and combine them
    local shortest_pairs = {};
    for i = 1, diff do
        local shortest = getShortest(sortedParagraphs, paragraphs);
        while shortest == false do
            shortest = getShortest(sortedParagraphs, paragraphs);
        end
        table.insert(shortest_pairs, shortest);
    end

    -- combine shortest pairs in paragraphs (original) array
    local remove_index = {}         -- track indeces to remove from paragraphs array (duplicates after combining)
    for i, p in ipairs(shortest_pairs) do
        local A = p[1] < p[2] and p[1] or p[2]
        local B = p[1] < p[2] and p[2] or p[1]

        --print("combining " .. A .. " and " .. B)
        paragraphs[A] = paragraphs[A] .. "\n\n" .. paragraphs[B];    -- combine to smaller index
        table.insert(remove_index, B);                               -- prep to remove large index
    end

    -- sort remove_index from largest to smalles
    --      (this way, we can preserve that larges tindeces first, 
    --          preserving array order for smaller indeces)
    table.sort(remove_index, function(a, b)
        return a > b
    end)
    for i, r in ipairs(remove_index) do
        --print(r)
        table.remove(paragraphs, r)          -- remove larger index
    end

end

function getShortest(sortedParagraphs, paragraphs)

    local result = {}
    local min = sortedParagraphs[1]     -- shortest paragraph 

    -- DEBUG
    -- print(sortedParagraphs[1])   
    -- print(min.text)

    -- pick shorter neighbor
    local pick_index = nil;
    local left_index = nil;
    local right_index = nil;
    if min > 1 then             
        -- has a "left" neighbor
        left_index = min - 1;
    end
    if min < #paragraphs then   
        -- has a "right" neighbor
        right_index = min + 1;
    end

    if (left_index == nil or arrayHas(sortedParagraphs, left_index) == false) and
    (right_index ~= nil and arrayHas(sortedParagraphs, right_index) ~= false) then 
        pick_index = right_index;
    elseif (right_index == nil or arrayHas(sortedParagraphs, right_index) == false) and
    (left_index ~= nil and arrayHas(sortedParagraphs, left_index) ~= false) then
        pick_index = left_index; 
    elseif (left_index == nil or arrayHas(sortedParagraphs, left_index) == false) and
    (right_index == nil or arrayHas(sortedParagraphs, right_index) == false) then
        table.remove(sortedParagraphs, 1);  
        return false
    else
        pick_index = #paragraphs[left_index] < #paragraphs[right_index] 
            and left_index or right_index     
    end

    -- DEBUG
    -- print(pick_index, min)

    -- remove pick from sortedParagraphs
    for i,v in pairs(sortedParagraphs) do
        if v == pick_index then
            table.remove(sortedParagraphs,i)
            break
        end
    end

    -- remove min from sortedParagraphs
    table.remove(sortedParagraphs, 1);  

    return {pick_index, min}
end

function arrayHas(arr, val)
    for i,v in pairs(arr) do
        if v == val then
            return true
        end
    end
    return false
end
