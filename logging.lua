-- OldAlert = pyui.alert
-- ---@overload fun(str: string):nil prevents crash when alert text exceeds 255 char
-- pyui.alert = function (...)
--     local str = string.sub(...,1,math.min(string.len(...),255))
--     OldAlert(str)
-- end

-- Convert a lua table into a lua syntactically correct string
function table_tostring(tbl, max_depth, func)
    max_depth = max_depth or 10
    func = func or tostring
    if type(tbl) ~= "table" then return tostring(tbl) end
    -- pyui.alert("going a level deeper, i = "..max_depth)
    if max_depth > 0 then
        local result = "{"
        for k, v in pairs(tbl) do
            -- Check the key type (ignore any numerical keys - assume its an array)
            if type(k) == "string" then
                result = result.."[\""..k.."\"]".."="
            end

            -- Check the value type
            if type(v) == "table" then
                result = result..table_tostring(v, max_depth-1)
            elseif type(v) == "boolean" then
                result = result..func(v)
            else
                result = result.."\"" .. func(v) .. "\""                    
            end
            result = result..","
        end
        -- Remove leading commas from the result
        if result ~= "" then
            result = result:sub(1, result:len()-1)
        end
        result = result.."}"
        return result
    end
    -- pyui.alert("max_depth reached")
    return "!md!"
end

function get_el_name(el)
    return el and pytha.get_element_attribute(el, 3)
end