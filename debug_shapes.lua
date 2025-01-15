-- provides the shape classes to be initialised

---@note all parameters are optional
function ux_arrow_3d(name, origin, axes, length, width, height, tail_length, tail_width)
    name = name or "ux_arrow_3d"
    length = length or 50
    width = width or 50
    height = height or 20
    tail_length = tail_length or (length and length*2)
    tail_width = tail_width or (width and width/2)
    axes = axes or {u_axis={1,0,0}}
    origin = origin or {0,0,0}

    pytha.push_local_coordinates(origin, axes)


    local face = pytha.create_polygon({
        {0, tail_width, 0},
        {tail_length, tail_width, 0},
        {tail_length, width, 0},
        {tail_length+length, 0, 0},
        {tail_length, -width, 0},
        {tail_length, -tail_width, 0},
        {0, -tail_width, 0}
    })
    local shape = pytha.create_profile(face, -height, {name=name})
    pytha.delete_element(face)

    pytha.create_element_ref_point(shape, {0,0,0}) --origin
    pytha.create_element_ref_point(shape, {tail_length+length, 0, 0}) --length
    pytha.create_element_ref_point(shape, {0, width, 0}) --width
    pytha.create_element_ref_point(shape, {0, 0, height}) --height
    pytha.pop_local_coordinates()

    return shape
end

---@note all parameters are optional
function ux_double_chevron_3d(name, origin, axes, length, width, height)
    name = name or "ux_arrow_3d"
    length = length or 50
    width = width or 100
    height = height or 20
    axes = axes or {u_axis={1,0,0}}
    origin = origin or {0,0,0}

    pytha.push_local_coordinates(origin, axes)
    local face = pytha.create_polygon({
        {0, width, 0},
        {length, width, 0},
        {length*2, 0, 0},
        {length, -width},
        {0, -width, 0},
        {length, 0, 0}
    })
    local shape_1 = pytha.create_profile(face, -height, {name="ux_chevron"})
    pytha.delete_element(face)
    local shape_2 = pytha.copy_element(shape_1, {length*2,0,0})

    local part = pytha.create_group(nil, {name=name})
    pytha.set_element_group(shape_1, part)
    pytha.set_element_group(shape_2, part)

    pytha.create_element_ref_point(part, {0,0,0}) --origin
    pytha.create_element_ref_point(part, {length*4, 0, 0}) --length
    pytha.create_element_ref_point(part, {0, width, 0}) --width
    pytha.create_element_ref_point(part, {0, 0, height}) --height
    pytha.pop_local_coordinates()

    return part
end

function ux_line_3d(name, origin, axes, length, width, height)
    name = name or "ux_line_3d"
    length = length or 50
    width = width or 100
    height = height or 20
    axes = axes or {u_axis={1,0,0}}
    origin = origin or {0,0,0}

    pytha.push_local_coordinates(origin, axes)
    local shape = pytha.create_block(length, width, height, nil, {name=name})

    pytha.create_element_ref_point(shape, {0,0,0}) --origin
    pytha.create_element_ref_point(shape, {length, 0, 0}) --length
    pytha.create_element_ref_point(shape, {0, width, 0}) --width
    pytha.create_element_ref_point(shape, {0, 0, height}) --height
    pytha.pop_local_coordinates()

    return shape
end


function ux_bounded_arrow_3d(name, origin, axes, length, width, height)
    name = name or "ux_bounded_arrow_3d"
    length = length or 150
    width = width or 100
    height = height or 20
    axes = axes or {u_axis={1,0,0}}
    origin = origin or {0,0,0}

    pytha.push_local_coordinates(origin, axes)
    local arrow = ux_arrow_3d(nil, nil, nil, length/3, width, height, length/3, width/2)
    local line = ux_line_3d(nil,
        {length, -width, 0},
        nil,
        -length/3,
        width*2,
        height
    )
    local part = pytha.create_group(arrow, {name=name})
    pytha.set_element_group(line, part)
    
    pytha.delete_element_ref_point(arrow)
    pytha.delete_element_ref_point(line)

    pytha.create_element_ref_point(part, {0,0,0})
    pytha.create_element_ref_point(part, {length, 0, 0})
    pytha.create_element_ref_point(part, {0, width, 0})
    pytha.create_element_ref_point(part, {0, 0, height})


    pytha.pop_local_coordinates()

    return part
end