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

            if ux_callback then
                ux_callback(move_vec)
            end
            if move_callback then
                move_callback(move_vec)
            end
            return move_vec
        end
    end
    return move_tool
end


---@return number ux_part_id, function update_callback
function create_ux_move_tool(data, origin, main_group, move_callback)
    local move_tool_part = {
        ux_part_id = nil,
        main_group = nil,
    }
    move_tool_part.tool = create_move_tool(data, origin, move_callback)
    move_tool_part.main_group = main_group or ux_arrow_3d(nil, origin)
    if not data.main_group then
        data.main_group = pytha.create_group(move_tool_part.main_group, {name=pyloc "UX_TESTING"})
    else
        pytha.set_element_group(move_tool_part.main_group, data.main_group)
    end
    move_tool_part.on_left_dragmove = function (info)
        move_tool_part.move((pyux.identify_coordinate(info.coos_vp) or {}).coos)
    end
    move_tool_part.move = function (origin)
        -- not sure if this coordinate logic should be seperated from the visual logic
        local move_vec = move_tool_part.tool.move(origin)
        if move_vec then
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

function create_ux_linesegment_tool(data, startpoint, endpoint, segments, update_callback)
    local tool_part = {
        ux_part_id = nil,
        main_group = nil,
    }
    local left_bound = ux_bounded_arrow_3d(pyloc "ux_left_bound", startpoint)
    local right_bound = ux_bounded_arrow_3d(pyloc "ux_right_bound", endpoint)
    -- local segment_handle = ux_line_3d(pyloc "ux_segment_handle", {
    --     (endpoint[1] - startpoint[1])/2 + startpoint[1],
    --     (endpoint[2] - startpoint[2])/2 + startpoint[2],
    --     (endpoint[3] - startpoint[3])/2 + startpoint[3]
    -- })
    tool_part.main_group = pytha.create_group(left_bound, {name=pyloc "ux_linesegment_tool"})
    pytha.set_element_group(right_bound, tool_part.main_group)
    pytha.set_element_group(segment_handle, tool_part.main_group)
    
    pytha.set_element_history(tool_part.main_group, {ux_part_id=tool_part.ux_part_id})
    local function update_part_direction(part, new_dir)
        local ux_ref_points = pytha.get_element_ref_point_coordinates(part)
        local current_dir = {
            ux_ref_points[2][1] - ux_ref_points[1][1],
            ux_ref_points[2][2] - ux_ref_points[1][2],
            ux_ref_points[2][3] - ux_ref_points[1][3],
        }

        local theta = ATAN(new_dir[2], new_dir[1]) - ATAN(current_dir[2], current_dir[1])
        -- local alpha = ATAN(current_endpoint[2], current_endpoint[3]) - ATAN(old_endpoint[2], old_endpoint[3])
        local origin = ux_ref_points[1]
        pytha.rotate_element(part, origin, {0,0,1}, theta)
        -- pytha.rotate_element(tool_part.tool.endpoint.main_group, origin, {1,0,0}, alpha)
    end
    tool_part.move_endpoint = function (endpoint)
        local startpoint = tool_part.tool.startpoint.tool.position
        local new_dir = {
            endpoint[1] - startpoint[1],
            endpoint[2] - startpoint[2],
            endpoint[3] - startpoint[3],
        }
        update_part_direction(tool_part.tool.endpoint.main_group, new_dir)
        update_part_direction(tool_part.tool.startpoint.main_group, {-new_dir[1], -new_dir[2], -new_dir[3]})

        tool_part.tool.endpoint.move(endpoint)
    end

    
    local function update_part()
        local new_dir = {
            tool_part.tool.endpoint.tool.position[1] - tool_part.tool.startpoint.tool.position[1],
            tool_part.tool.endpoint.tool.position[2] - tool_part.tool.startpoint.tool.position[2],
            tool_part.tool.endpoint.tool.position[3] - tool_part.tool.startpoint.tool.position[3]
        }
        update_part_direction(tool_part.tool.endpoint.main_group, new_dir)
        update_part_direction(tool_part.tool.startpoint.main_group, {-new_dir[1], -new_dir[2], -new_dir[3]})
    end

    tool_part.tool = {
        startpoint = data.ux_parts[create_ux_move_tool(data, startpoint, left_bound, update_part)],
        endpoint = data.ux_parts[create_ux_move_tool(data, startpoint, right_bound, update_part)],
        -- segment_period = data.ux_parts[create_ux_move_tool(data, startpoint, segment_handle)]
    }

    return tool_part
end