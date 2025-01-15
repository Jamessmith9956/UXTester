if not ux_parts_types then
    ux_part_types = {}
end

local movement = {
    origin = {0,0,0},
    endpoint = {0,0,0}
}


local function snap_point(point, options)
    return point
end

function create_move_tool(data, origin, move_callback, ux_callback)
    local move_tool = {
        position = origin or {0,0,0},
    }
    move_tool.move = function (new_pos)
        if new_pos then
            -- apply snapping 

            local move_vec = {
                new_pos[1] - move_tool.position[1],
                new_pos[2] - move_tool.position[2],
                new_pos[3] - move_tool.position[3],
            }
            move_tool.position = new_pos
            return move_vec
        end
    end
    return move_tool
end


---@return number ux_part_id, function update_callback
function create_ux_movetool(data, origin, move_callback)
    local move_tool_part = {
        ux_part_id = nil,
        main_group = nil,
    }
    move_tool_part.tool = create_move_tool(data, origin)
    move_tool_part.main_group = ux_arrow_3d(nil, origin)
    if not data.main_group then
        data.main_group = pytha.create_group(move_tool_part.main_group, {name=pyloc "UX_TESTING"})
    else
        pytha.set_element_group(move_tool_part.main_group, data.main_group)
    end
    move_tool_part.on_left_dragmove = function (info)
        -- not sure if this coordinate logic should be seperated from the visual logic
        local move_vec = move_tool_part.tool.move(pyux.identify_coordinate(info.coos_vp).coos)
        if move_vec then
            move_callback(move_vec)
            pytha.move_element(move_tool_part.main_group, move_vec)
        end
    end

    -- not sure how to keep the ux elements upto date. should the object provide a subscription function?
    move_tool_part.update = function(origin)
        -- local move_vec = move_tool_part.tool.move(origin)
        -- pytha.move_element(move_tool_part.main_group, move_vec)
        pytha.move_element(move_tool_part.main_group, {
            origin[1] - move_tool_part.tool.position[1],
            origin[2] - move_tool_part.tool.position[2],
            origin[3] - move_tool_part.tool.position[3],
        })
        move_tool_part.tool.position = origin
    end

    table.insert(data.ux_parts, move_tool_part)
    move_tool_part.ux_part_id = #data.ux_parts
    pytha.set_element_history(move_tool_part.main_group, {ux_part_id=move_tool_part.ux_part_id})


    return move_tool_part.ux_part_id, move_tool_part.update
end