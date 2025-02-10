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
    -- UX handlers

    local drag_btn = dialog_handle:create_button(1, pyloc "drag and drop")
    drag_btn:set_on_click_handler(function()
        pyux.set_on_left_dragstart_handler(function (info) pyui.alert("this should never be reached") end)
        pyux.set_on_left_dragmove_handler(function (info) pyui.alert("here") end)
        pyux.set_on_left_dragend_handler(function (info) pyui.alert("where") end)
        pyux.start_left_drag()
    end)

    local drag_drop_list = dialog_handle:create_drop_list(1)
    drag_drop_list:insert_control_item(pyloc "a")
    drag_drop_list:insert_control_item(pyloc "b")
    drag_drop_list:set_on_change_handler(function(text, new_index)
        pyui.run_modal_subdialog(function(dialog)
            pyux.set_on_left_dragstart_handler(function (info) pyui.alert("this should never be reached") end)
            pyux.set_on_left_dragmove_handler(function (info) pyui.alert("here") end)
            pyux.set_on_left_dragend_handler(function (info) pyui.alert("where") end)
            -- pyux.set_on_left_dragend_handler(function (info) pyux.set_on_left_dragstart_handler() end)
            pyux.set_on_left_click_handler(function(info)
                pyux.set_on_left_dragstart_handler(nil)
                pyux.set_on_left_dragmove_handler(nil)
                pyux.set_on_left_dragend_handler(nil)
            end)
            pyux.show_cursor_crosshair(true)
            -- pyux.start_left_drag()
        end)
    end)

end
