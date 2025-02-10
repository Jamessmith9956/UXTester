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

    local drag_btn = dialog_handle:create_button(1, pyloc "drag and drop")
    drag_btn:set_on_click_handler(function()
        pyui.alert("Pause Execution, move cursor off of dialog before continuing")
        pyux.set_on_left_dragstart_handler(function (info) pyui.alert("this should never be reached") end)
        pyux.set_on_left_dragmove_handler(function (info) pyui.alert("here") end)
        pyux.set_on_left_dragend_handler(function (info) pyui.alert("where") end)
        pyux.start_left_drag()
    end)

    pyux.set_on_left_click_handler(function(info) pyui.run_modal_subdialog(function(dialog)
        dialog:set_window_title("UX Tester Obstruction Window")
        dialog:create_label(1, "")
        dialog:create_label(1, "")
        dialog:create_label(1, "")
        dialog:create_label(1, "")
        dialog:create_button(1, pyloc "Dummy button")
        
        pyux.set_on_left_dragstart_handler(function (info) pyui.alert("this should never be reached") end)
        pyux.set_on_left_dragmove_handler(function (info) pyui.alert("here") end)
        pyux.set_on_left_dragend_handler(function (info) pyui.alert("where") end)
        pyux.start_left_drag()
    end)end)

end
