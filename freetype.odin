package freetype

import "core:c"

when ODIN_OS == "windows" {
	foreign import freetype "freetype.lib";
}

Library       :: distinct rawptr

Bool          :: distinct c.uchar
Error         :: distinct c.int
F26Dot6       :: distinct c.long
Fixed         :: distinct c.long
Pos           :: distinct c.long

Char_Map      :: ^Char_Map_Rec
Driver        :: ^Driver_Rec
Driver_Class  :: ^Driver_Class_Rec
Face          :: ^Face_Rec
Glyph_Loader  :: ^Glyph_Loader_Rec
Glyph_Slot    :: ^Glyph_Slot_Rec
List_Node     :: ^List_Node_Rec
Memory        :: ^Memory_Rec
Module        :: ^Module_Rec
Size          :: ^Size_Rec
Size_Request  :: ^Size_Request_Rec
Stream        :: ^Stream_Rec
Sub_Glyph     :: ^Sub_Glyph_Rec

// Keeping internals rawptr for now.

Face_Internal :: rawptr
Size_Internal :: rawptr
Slot_Internal :: rawptr

Alloc_Func             :: #type proc "c" (memory: Memory, size: c.long) -> rawptr
Free_Func              :: #type proc "c" (memory: Memory, block: rawptr)
Realloc_Func           :: #type proc "c" (memory: Memory, cur_size, new_size: c.long, block: rawptr) -> rawptr

Generic_Finalizer      :: #type proc "c" (object: rawptr)

Face_Attach_Func       :: #type proc "c" (face: Face, stream: Stream) -> Error
Face_Init_Func         :: #type proc "c" (stream: Stream, face: Face, typeface_index, num_params: c.int, parameters: ^Parameter) -> Error
Face_Done_Func         :: #type proc "c" (face: Face)
Face_Get_Advances_Func :: #type proc "c" (face: Face, first, count: c.uint, flags: i32, advances: ^Fixed) -> Error
Face_Get_Kerning_Func  :: #type proc "c" (face: Face, left_glyph, right_glyph: c.uint, kerning: ^Vector) -> Error

Module_Constructor     :: #type proc "c" (module: Module) -> Error
Module_Destructor      :: #type proc "c" (module: Module)
Module_Requester       :: #type proc "c" (module: Module, name: cstring) -> rawptr

Size_Init_Func         :: #type proc "c" (size: Size) -> Error
Size_Done_Func         :: #type proc "c" (size: Size)
Size_Request_Func      :: #type proc "c" (size: Size, req: Size_Request) -> Error
Size_Select_Func       :: #type proc "c" (size: Size, size_index: c.ulong) -> Error

Slot_Init_Func         :: #type proc "c" (slot: Glyph_Slot) -> Error
Slot_Done_Func         :: #type proc "c" (slot: Glyph_Slot)
Slot_Load_Func         :: #type proc "c" (slot: Glyph_Slot, size: Size, glyph_index: c.uint, load_flags: i32) -> Error

Stream_IO_Func         :: #type proc "c" (stream: Stream, offset: c.ulong, buffer: ^c.uchar, count: c.ulong) -> c.ulong
Stream_Close_Func      :: #type proc "c" (stream: Stream)

B_Box :: struct {
    x_min, y_min, x_max, y_max : Pos,
}

Bitmap :: struct {
    rows         : c.uint,
    width        : c.uint,
    pitch        : c.int,
    buffer       : ^c.uchar,
    num_grays    : c.ushort,
    pixel_mode   : c.char,
    palette_mode : c.uchar,
    palette      : rawptr,
}

Bitmap_Size :: struct {
    height : i16,
    width  : i16,

    size   : Pos,

    x_ppem : Pos,
    y_ppem : Pos,
}

Char_Map_Rec :: struct {
    face        : Face,
    encoding    : Encoding,
    platform_id : c.ushort,
    encoding_id : c.ushort,
}

Driver_Class_Rec :: struct {
    root             : Module_Class,

    face_object_size : c.long,
    size_object_size : c.long,
    slot_object_size : c.long,

    init_face        : Face_Init_Func,
    done_face        : Face_Done_Func,

    init_size        : Size_Init_Func,
    done_size        : Size_Done_Func,

    init_slot        : Slot_Init_Func,
    done_slot        : Slot_Done_Func,

    load_glyph       : Slot_Load_Func,

    get_kerning      : Face_Get_Kerning_Func,
    attach_file      : Face_Attach_Func,
    get_advances     : Face_Get_Advances_Func,

    request_size     : Size_Request_Func,
    select_size      : Size_Select_Func,
}

Driver_Rec :: struct {
    root         : Module_Rec,
    clazz        : Driver_Class,
    face_list    : List_Rec,
    glyph_loader : Glyph_Loader,
}

Encoding :: enum {
    // TODO
}

Face_Rec :: struct {
    num_faces           : c.long,
    face_index          : c.long,

    face_flags          : c.long,
    style_flags         : c.long,

    num_glyphs          : c.long,

    family_name         : cstring,
    style_name          : cstring,

    num_fixed_sizes     : c.int,
    available_sizes     : Bitmap_Size,

    num_charmaps        : c.int,
    charmaps            : ^Char_Map,

    generic             : Generic,

    bbox                : B_Box,

    units_per_em        : c.ushort,
    ascender            : c.short,
    descender           : c.short,
    height              : c.short,

    max_advance_width   : c.short,
    max_advance_height  : c.short,

    underline_position  : c.short,
    underline_thickness : c.short,

    glyph               : Glyph_Slot,
    size                : Size,
    charmap             : Char_Map,

    driver              : Driver,
    memory              : Memory,
    stream              : Stream,

    sizes_list          : List_Rec,

    auto_hint           : Generic,
    extensions          : rawptr,

    internal            : Face_Internal,
}

Generic :: struct {
    data      : rawptr,
    finalizer : Generic_Finalizer,
}

Glyph_Format :: enum {
    // TODO
}

Glyph_Load_Rec :: struct {
    outline       : Outline,
    extra_points  : ^Vector,
    extra_points2 : ^Vector,
    num_subglyphs : c.uint,
    subglyphs     : Sub_Glyph,
}

Glyph_Loader_Rec :: struct {
    memory    : Memory,
    points    : c.uint,
    contours  : c.uint,
    subglyphs : c.uint,
    extra     : Bool,

    base      : Glyph_Load_Rec,
    current   : Glyph_Load_Rec,

    other     : rawptr,
}

Glyph_Metrics :: struct {
    width          : Pos,
    height         : Pos,

    hori_bearing_x : Pos,
    hori_bearing_y : Pos,
    hori_advance   : Pos,

    vert_bearing_x : Pos,
    vert_bearing_y : Pos,
    vert_advance   : Pos,
}

Glyph_Slot_Rec :: struct {
    library             : Library,
    face                : Face,
    next                : Glyph_Slot,
    glyph_index         : c.uint,
    generic             : Generic,

    metrics             : Glyph_Metrics,
    linear_hori_advance : Fixed,
    linear_vert_advance : Fixed,
    advance             : Vector,

    format              : Glyph_Format,

    bitmap              : Bitmap,
    bitmap_left         : c.int,
    bitmap_top          : c.int,

    outline             : Outline,

    num_subglyphs       : c.uint,
    subglyphs           : Sub_Glyph,

    control_data        : rawptr,
    control_len         : c.long,

    lsb_delta           : Pos,
    rsb_delta           : Pos,

    other               : rawptr,

    internal            : Slot_Internal,
}

List_Node_Rec :: struct {
    prev, next: List_Node,
    data      : rawptr,
}

List_Rec :: struct {
    head, tail: List_Node,
}

Load_Flags :: enum i32 {
    Default                     = 0,
    No_Scale                    = 1 << 0,
    No_Hinting                  = 1 << 2,
    Render                      = 1 << 3,
    No_Bitmap                   = 1 << 4,
    Vertical_Layout             = 1 << 5,
    Force_Autohint              = 1 << 6,
    Crop_Bitmap                 = 1 << 7,
    Pedantic                    = 1 << 8,
    Ignore_Global_Advance_Width = 1 << 9,
    No_Recurse                  = 1 << 10,
    Ignore_Transform            = 1 << 11,
    Monochrome                  = 1 << 12,
    Linear_Design               = 1 << 13,
    No_Autohint                 = 1 << 15,
    Color                       = 1 << 20,
    Compute_Metrics             = 1 << 21,
    Bitmap_Metrics_Only         = 1 << 22,
    Advance_Only                = 1 << 8,
    S_Bits_Only                 = 1 << 14,
}

Matrix :: struct {
    xx, xy, yx, yy : Fixed,
}

Memory_Rec :: struct {
    user    : rawptr,
    alloc   : Alloc_Func,
    free    : Free_Func,
    realloc : Realloc_Func,
}

Module_Class :: struct {
    module_flags     : c.ulong,
    module_size      : c.long,
    module_name      : cstring,
    module_version   : Fixed,
    module_requires  : Fixed,

    module_interface : rawptr,

    module_init      : Module_Constructor,
    module_done      : Module_Destructor,
    get_interface    : Module_Requester,
}

Module_Rec :: struct {
    clazz   : ^Module_Class,
    library : Library,
    memory  : Memory,
}

Outline :: struct {
    n_contours : c.short,
    n_points   : c.short,

    points     : ^Vector,
    tags       : ^c.char,
    contours   : ^c.short,

    flags      : c.int,
}

Parameter :: struct {
    tag  : c.ulong,
    data : rawptr,
}

Size_Metrics :: struct {
    x_ppem      : c.ushort,
    y_ppem      : c.ushort,

    x_scale     : Fixed,
    y_scale     : Fixed,

    ascender    : Pos,
    descender   : Pos,
    height      : Pos,
    max_advance : Pos,
}

Size_Rec :: struct {
    face     : Face,
    generic  : Generic,
    metrics  : Size_Metrics,
    internal : Size_Internal,
}

Size_Request_Rec :: struct {
    type            : Size_Request_Type,
    width           : c.long,
    height          : c.long,
    hori_resolution : c.uint,
    vert_resolution : c.uint,
}

Size_Request_Type :: enum {
    Normal   = 0,
    Real_Dim = 1,
    B_Box    = 2,
    Cell     = 3,
    Scale    = 4,

    Max      = 5,
}

Stream_Desc :: struct {
    value  : c.long,
    ponter : rawptr,
}

Stream_Rec :: struct {
    base       : ^c.uchar,
    size       : c.ulong,
    pos        : c.ulong,

    descriptor : Stream_Desc,
    pathname   : Stream_Desc,
    read       : Stream_IO_Func,
    close      : Stream_Close_Func,

    memory     : Memory,
    cursor     : ^c.uchar,
    limit      : ^c.uchar,
}

Sub_Glyph_Rec :: struct {
    index     : c.int,
    flags     : c.ushort,
    arg1      : c.int,
    arg2      : c.int,
    transform : Matrix,
}

Vector :: struct {
    x, y : Pos,
}

@(default_calling_convention="c")
foreign freetype {
    @(link_name="FT_Init_FreeType") init_free_type :: proc(library: ^Library) -> Error ---
    @(link_name="FT_Done_FreeType") done_free_type :: proc(library: Library) -> Error ---

    @(link_name="FT_New_Face")        new_face        :: proc(library: Library, file_path_name: cstring, face_index: c.long, face: ^Face) -> Error ---
    @(link_name="FT_New_Memory_Face") new_memory_face :: proc(library: Library, file_base: ^byte, file_size, face_index: c.long, face: ^Face) -> Error ---

    @(link_name="FT_Load_Char")     load_char     :: proc(face: Face, char_code: c.ulong, load_flags: Load_Flags) -> Error ---
    @(link_name="FT_Set_Char_Size") set_char_size :: proc(face: Face, char_width, char_height: F26Dot6, horz_resolution, vert_resolution: c.uint) -> Error ---
}