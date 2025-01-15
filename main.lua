function main()
    local data = {
        ux_parts = {},
        parts = {},
        lines = {},
        main_group = nil,
    }
    local result = pyui.run_modal_subdialog(main_dialog, data)
    if result ~= "ok" then
        if data.main_group then
            pytha.delete_element(data.main_group)
        end
    end
end


function main_dialog(dialog_handle, data)
    dialog_handle:set_window_title(pyloc "UX Demo project")
    dialog_handle:equalize_column_widths({1,2})

    local split_line = dialog_handle:create_button(1, pyloc "split line")

    local log_a = dialog_handle:create_text_display({1,2})

    -- handlers
    split_line:set_on_click_handler(function ()
        init_split_line(data)
    end)

    -- UX handlers
    pyux.set_on_left_click_handler(function (info)
        local part = pyux.identify_part(info.coos_vp)
        if part then
            local bb = pytha.get_element_bounding_box(part)
            bb[1][1] = bb[1][1] -100
            local id, callback = create_ux_movetool(data, bb[1], function (move_vec)
                pytha.move_element(part, move_vec)
            end)
            table.insert(data.parts, {ux_parts = {id}, update_callbacks={callback}})
            pytha.set_element_history(part, {part_id=#data.parts})
        end
    end)
    pyux.set_on_left_dragstart_handler(function (info)
        local part = pyux.identify_part(info.coos_vp)
        if part then
            local part_hist = pytha.get_element_history(part)
            if part_hist and part_hist.ux_part_id and data.ux_parts[part_hist.ux_part_id] ~=nil then
                local tool = data.ux_parts[part_hist.ux_part_id]
                if tool.on_left_dragstart then
                    tool.on_left_dragstart(info)
                end
                if tool.on_left_dragmove then
                    pyux.set_on_left_dragmove_handler(tool.on_left_dragmove)
                end
                if tool.on_left_dragend then
                    pyux.set_on_left_dragmend_handler(tool.on_left_dragend)
                end
            else
                local origin = pyux.identify_coordinate(info.coos_vp).coos
                local move_tool = create_move_tool(data, origin)
                pyux.set_on_left_dragmove_handler(function (info)
                    local move_vec = move_tool.move(pyux.identify_coordinate(info.coos_vp).coos)
                    if move_vec then
                        pytha.move_element(part, move_vec)
                        if part_hist and part_hist.part_id and data.parts[part_hist.part_id] then
                            for i, ux_part_id in pairs(data.parts[part_hist.part_id].ux_parts) do
                                -- pyui.alert(table_tostring(data.ux_parts[ux_part_id]))
                                data.ux_parts[ux_part_id].update({
                                    data.ux_parts[ux_part_id].tool.position[1] + move_vec[1],
                                    data.ux_parts[ux_part_id].tool.position[2] + move_vec[2],
                                    data.ux_parts[ux_part_id].tool.position[3] + move_vec[3]
                                })
                            end
                            --     -- this doesn't work. we need the updater to handle itself somehow.
                            --     -- at the sametime we need to have a general handler so that can reuse it.
                            -- for i, callback in pairs(data.parts[part_hist.part_id].update_callbacks) do
                            --     callback(origin)
                            -- end
                        end
                    end
                end)
            end
        end
    end)

end
