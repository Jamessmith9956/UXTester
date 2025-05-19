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
end
