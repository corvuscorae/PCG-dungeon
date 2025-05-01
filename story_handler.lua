-- RAVEN
function combineShortest(diff, paragraphs, objectives)
    -- print(diff)
    
    -- make a sorted version of paragraphs
    local sortedParagraphs = {};
    for i, p in ipairs(paragraphs) do
        sortedParagraphs[i] = {
            story_index = i,
            text =  p.text
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
        paragraphs[A].text = paragraphs[A].text .. "\n\n" .. paragraphs[B].text;    -- combine to smaller index
        paragraphs[A].index = merge_tables(paragraphs[A].index, paragraphs[B].index);
        paragraphs[A].objectives = merge_tables(paragraphs[A].objectives, paragraphs[B].objectives);
        resolveMergedObjectives(paragraphs[A], paragraphs[B], objectives);
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

function resolveMergedObjectives(paragraphA, paragraphB, objectives)
    -- auto-resolve any objectives whose resolution is in the other paragraph
    for i,obj in pairs(paragraphA.objectives) do
        for j,ind in pairs(paragraphB.index) do
            if arrayHas(obj.resolution_at, ind) then
                table.insert(objectives.resolved.obj, obj);
                table.insert(objectives.resolved.index, obj.index);
            end
        end
    end
    for i,obj in pairs(paragraphB.objectives) do
        for j,ind in pairs(paragraphA.index) do
            if arrayHas(obj.resolution_at, ind) then
                table.insert(objectives.resolved.obj, obj);
                table.insert(objectives.resolved.index, obj.index);
            end
        end
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

function getObjectives(paragraph, history, active, resolved)
    -- add objective from paragraph to active_objective 
    --      IFF resolution has not yet been seen
    for i,obj in pairs(paragraph.objectives) do
        local add = true
        
        if arrayHas(resolved.index, obj.index) == true then
            goto continue
        end
        
        if arrayHas(active.index, obj.index) == true then
            goto continue
        end

        for j,res in pairs(obj.resolution_at) do
            --print(res)
            if arrayHas(history, res) == true then
                add = false;
                break;
            end
        end

        if add == true then
            print("NEW OBJECTIVE: " .. obj.text)
            table.insert(active.obj, obj);
            table.insert(active.index, obj.index);
        end

        :: continue ::
    end
end

function resolveObjective(paragraph, active, resolved)
    -- check to see if any of the active objectives have a resolution in this room
    for i,obj in pairs(active.obj) do
        --print("---")
        --print(tostring(obj.text))
        for i,ind in pairs(paragraph.index) do
            --print(tostring(ind))
            if arrayHas(obj.resolution_at, ind) then
                print("RESOLVED: " .. obj.text)
                table.insert(resolved.obj, obj);
                table.insert(resolved.index, obj.index);

                local activeIndex = indexOf(active.index, obj.index);
                if activeIndex ~= nil then 
                    table.remove(active.index, activeIndex);
                    table.remove(active.obj, activeIndex);      -- should be the same index
                end
            end
        end
        
    end
    --print("-----------------")
end

function indexOf(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil  
end

function arrayHas(arr, val)
    for i,v in pairs(arr) do
        if v == val then
            return true
        end
    end
    return false
end

function deepCopy(orig, seen)
    if type(orig) ~= 'table' then
        return orig
    end

    if seen and seen[orig] then
        return seen[orig]
    end

    local copy = {}
    seen = seen or {}
    seen[orig] = copy

    for k, v in pairs(orig) do
        copy[deepCopy(k, seen)] = deepCopy(v, seen)
    end

    setmetatable(copy, getmetatable(orig)) 
    return copy
end

function merge_tables(t1, t2)
    local result = {}
    for k, v in pairs(t1) do
        table.insert(result, v)
    end
    for k, v in pairs(t2) do
        table.insert(result, v)
    end
    return result
end