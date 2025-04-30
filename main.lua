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




--I can get the drag to start correctly if I move the cursor from the current dialog into the graphics area before the drag starts, using an alert to pause the execution.

--It will also start correctly if pyux.start_left_drag() is called from another click/drag handler, even if the cursor sits on top of the current dialog when the drag starts.

function main_dialog(dialog_handle, data)
    dialog_handle:set_window_title(pyloc "UX Demo project")
    dialog_handle:equalize_column_widths({1,2})
    -- UX handlers
    local log_a = dialog_handle:create_text_box(1)
    log_a:enable_control(false)

    local ux_part_name_lookup = {
        {name=pyloc "Arrow 3D", func=ux_arrow_3d},
        {name=pyloc "Bounded Arrow 3D", func=ux_bounded_arrow_3d},
        {name=pyloc "Double Chevron 3D", func=ux_double_chevron_3d},
        {name=pyloc "Line 3D", func=ux_line_3d},
        {name=pyloc "Sphere", func=ux_sphere_3d},
    }
    local ux_part_selection = dialog_handle:create_list_box({1,2}, pyloc "UX Parts")
    for i, k in ipairs(ux_part_name_lookup) do
        ux_part_selection:insert_control_item(k.name)
    end
    local current_ux_part_idx = 1
    ux_part_selection:set_control_selection(current_ux_part_idx)

    local drag_btn = dialog_handle:create_button(1, pyloc "drag and drop")
    drag_btn:set_on_click_handler(function()
        drag_btn.state = not drag_btn.state
        local origin_vp, terminus_vp = nil, nil
        pyux.set_on_left_dragstart_handler(function (info) end)
        pyux.set_on_left_dragmove_handler(function (info) log_a:set_control_text(table_tostring(info.coos_vp)) end)
        pyux.set_on_left_dragend_handler(function (info)
            origin_vp = info.coos_vp
            pyux.set_on_left_dragstart_handler(function (info) end)
            pyux.set_on_left_dragmove_handler(function(info) end)
            pyux.set_on_left_dragend_handler(function(info) 
                terminus_vp = info.coos_vp
                local origin = pyux.identify_coordinate_on_plane(origin_vp, {0,0,0}, {0,0,1})
                local terminus = pyux.identify_coordinate_on_plane(terminus_vp, {0,0,0}, {0,0,1})
                local u_axis = {
                    terminus[1] - origin[1],
                    terminus[2] - origin[2],
                    terminus[3] - origin[3],
                }
                local length = PYTHAGORAS(u_axis[1], u_axis[2], u_axis[3])
                if length>0 then
                    u_axis = {
                        u_axis[1]/length,
                        u_axis[2]/length,
                        u_axis[3]/length,
                    }
                end

                local func = ux_part_name_lookup[current_ux_part_idx].func
                if func then
                    local part = func(nil, origin, {u_axis=u_axis}, length, nil, nil, nil, nil)
                    table.insert(data.parts, part)
                    if not data.main_group then
                        data.main_group = pytha.create_group(part, {name=pyloc"main_group"})
                    else
                        pytha.set_element_group(part, data.main_group)
                    end
                end
            end)
            pyux.start_left_drag()
        end)
        pyux.start_left_drag()
    end)

    ux_part_selection:set_on_change_handler(function (text, index)
        current_ux_part_idx = index
    end)
end
