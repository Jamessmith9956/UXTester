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

    local block_list = {
        ux_sphere_3d,
        ux_sphere_3d,
        ux_sphere_3d,
        ux_sphere_3d,
    }
    local grp_1_els = {}
    local grp_2_els = {}
    local grp_1, grp_2
    local draw_block_btn = dialog_handle:create_button(2, pyloc "Re Create Demo Spheres")
    draw_block_btn:set_on_click_handler(function ()
        -- pyui.alert("a")
        if not data.main_group then
            data.main_group = pytha.create_group({}, {name= "Main Group"})
        end
        pyui.alert("Main Group established")

        if grp_1 then
            pytha.delete_element(grp_1)
        end
        pyui.alert("First Element Deleted")

        if grp_2 then
            pytha.delete_element(grp_2)
        end
        pyui.alert("Final Element Deleted, Main Group dropped")

        local radius = 150
        grp_1_els[1] = block_list[1]("part_1", {0,0,0}, nil, radius)
        grp_1_els[2] = block_list[2]("part_2", {radius*1*2,0,0}, nil, radius)
        grp_2_els[1] = block_list[3]("part_3", {radius*2*2,0,0}, nil, radius)
        grp_2_els[2] = block_list[4]("part_4", {radius*3*2,0,0}, nil, radius)
        -- pyui.alert("d")

        grp_1 = pytha.create_group(grp_1_els, {name = "Balls Grp 1"})
        grp_2 = pytha.create_group(grp_2_els, {name = "Balls Grp 2"})
        pyui.alert("Recreated Elements")
        pytha.set_element_group({grp_1, grp_2}, data.main_group)
        pyui.alert("Elements attached to dropped Main Group")
    end)

    dialog_handle:create_label(1, pyloc "Global Coos")
    dialog_handle:create_label(2, pyloc "Local Coos")
    local log_b = dialog_handle:create_text_box(1)
    local log_c = dialog_handle:create_text_box(2)
    dialog_handle:create_label({1,2}, pyloc "local corordinate system")
    local log_d = dialog_handle:create_text_box(1)
    local log_e = dialog_handle:create_text_box(2)
    local function test_coordinate_in_area(info)
        local origin = {2000,0,0}
        local direction = {1,0,0}
        local global_coos = pyux.identify_coordinate(info.coos_vp)
        global_coos = global_coos and global_coos.coos or {}
        pytha.push_local_coordinates(origin, direction)
        local coos = pyux.identify_coordinate(info.coos_vp)
        coos = coos and coos.coos or {}
        pytha.pop_local_coordinates()
        log_b:set_control_text("{" .. pyui.format_length(global_coos[1]) .. ", " .. pyui.format_length(global_coos[2]) .. ", " .. pyui.format_length(global_coos[3]) .. "}")
        log_c:set_control_text("{" .. pyui.format_length(coos[1]) .. ", " .. pyui.format_length(coos[2]) .. ", " .. pyui.format_length(coos[3]) .. "}")

        log_d:set_control_text("{"..pyui.format_length(origin[1])..", "..pyui.format_length(origin[2])..", "..pyui.format_length(origin[3]).."}")
        log_e:set_control_text("{"..pyui.format_length(direction[1])..", "..pyui.format_length(direction[2])..", "..pyui.format_length(direction[3]).."}")
    end
    pyux.set_on_left_click_handler(function (info)
        test_coordinate_in_area(info)
    end)
    local test_coordinate_in_area_btn = dialog_handle:create_button({1,2}, pyloc "Test Coordinate in Area")
    test_coordinate_in_area_btn:set_on_click_handler(function ()
        pyux.set_on_left_dragstart_handler(function (info) end)
        pyux.set_on_left_dragmove_handler(function (info) end)
        pyux.set_on_left_dragend_handler(function (info)
            test_coordinate_in_area(info)
            pyux.set_on_left_dragstart_handler(nil)
        end)
        pyux.start_left_drag()

    end)
end
