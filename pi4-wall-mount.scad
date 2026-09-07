// ============================================================================
// Raspberry Pi 4 case -> wall-mount cradle (ikea-type shelf side wall)
// Mounted pose: case flat against the wall, power/HDMI edge UP. Held by a floor
// + short front lip + a side lip along the USB/Ethernet edge. Back plate screws
// to the shelf board (countersunk). Inside 45-deg fillets mate the case's
// bottom chamfers.
//
// Coords: X = horizontal (along wall), Y = out from wall, Z = up. Units: mm.
// The USB/Ethernet ("back") edge is the +X side; the case protrusion is on the
// far (-X) side, so the front lip is offset toward +X to clear it.
// Set usb_on_right=false to mirror everything to the other hand.
// ============================================================================

/* ===== CASE (measured, assembled, as mounted) ===== */
case_w = 108;    // horizontal width against the wall
case_h = 70;     // vertical height
case_d = 35.5;   // depth out from the wall
case_chamfer = 5;// case's 45-deg bottom-edge chamfer (measured); drives inside fillets
fit    = 0.6;    // clearance around the case

/* ===== BACK PLATE ===== */
plate_th   = 4;
top_margin = 16;   // strip above the case (top screws)

/* ===== CRADLE ===== */
floor_th     = 4;
front_lip_th = 3;
front_lip_h  = 18;
front_lip_w  = 91;   // < case_w, offset toward +X to clear the far-side protrusion
side_lip_th  = 3;    // lip along the USB/Ethernet (+X) edge
side_lip_h   = 5;    // its height above the floor

/* ===== WOOD SCREWS (countersunk; 1" #8) ===== */
screw_shank_d = 4.5;
head_d        = 9.0;
cs_angle      = 82;
// Hole layout on a 25mm lattice so it drops onto Multiboard (25mm tile pitch):
// two top holes 100mm apart, one low-center hole 50mm below -> all spacings x25.
screw_grid    = 25;
screw_top_x   = 50;    // top pair at +/- this (must be a multiple of screw_grid)
screw_low_dz  = 50;    // low-center hole this far below the top row (multiple of grid)

usb_on_right   = true;   // false = mirror to the other hand
show_case_ghost = true;
$fn = 64;

/* ===== derived ===== */
yc0 = plate_th;                 // case back (flush on plate)
yc1 = yc0 + case_d;             // case front
yfl0 = yc1 + fit;               // front lip inner
yfl1 = yfl0 + front_lip_th;     // front lip outer
plate_h = floor_th + case_h + top_margin;
xr = case_w/2 + fit + side_lip_th;          // +X edge (includes the side lip)
xl = -xr;                                   // symmetric plate -> even screw margins
fl_x1 = xr;                                 // +X end reaches out to meet the side lip
fl_x0 = case_w/2 - front_lip_w;             // far (-X) end
cs_depth = (head_d - screw_shank_d)/2 / tan(cs_angle/2);
screw_z_top = plate_h - top_margin/2;

module box(x0,x1,y0,y1,z0,z1) translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]);

// 45-deg inside fillet along X (concave floor/wall corner), dir=+1 opens +Y
module fillet_x(x0,x1, yc,zc, size, dir)
    translate([x0,0,0]) rotate([90,0,90]) linear_extrude(x1-x0)
        polygon([[yc,zc],[yc+dir*size,zc],[yc,zc+size]]);

module cs_hole(x,z) translate([x,0,z]) rotate([-90,0,0]) {
    translate([0,0,-1]) cylinder(d=screw_shank_d, h=plate_th+2);
    translate([0,0,plate_th-cs_depth]) cylinder(d1=screw_shank_d, d2=head_d+0.4, h=cs_depth+0.2);
}

module bracket() {
    difference() {
        union() {
            box(xl, xr, 0, plate_th, 0, plate_h);                       // back plate
            box(xl, xr, plate_th, yfl1, 0, floor_th);                   // floor
            box(fl_x0, fl_x1, yfl0, yfl1, 0, floor_th + front_lip_h);   // front lip (offset +X)
            box(case_w/2 + fit, xr, yc0, yfl1, 0, floor_th + side_lip_h);// side lip (extends to meet the front lip)
            fillet_x(-case_w/2, case_w/2, yc0, floor_th, case_chamfer, +1); // back-bottom fillet
            fillet_x(fl_x0, fl_x1,        yfl0, floor_th, case_chamfer, -1); // front-bottom fillet (flush to front lip)
        }
        cs_hole(-screw_top_x, screw_z_top);
        cs_hole( screw_top_x, screw_z_top);
        cs_hole(0, screw_z_top - screw_low_dz);
    }
    if (show_case_ghost)
        %translate([-case_w/2, yc0, floor_th]) cube([case_w, case_d, case_h]);
}

if (usb_on_right) bracket();
else mirror([1,0,0]) bracket();
