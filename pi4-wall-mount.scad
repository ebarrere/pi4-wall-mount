// ============================================================================
// Raspberry Pi 4 case -> wall-mount cradle (ikea-type shelf side wall)
// Mounted pose: case against the wall, power/HDMI edge UP, held in a bottom
// cradle (floor + short front lip + low back lip). Back plate screws to the
// shelf board with countersunk wood screws. Inside 45-deg fillets mate the
// case's bottom chamfers so it seats flush.
//
// Coords: X = horizontal (along wall), Y = out from wall, Z = up. Units: mm.
// ============================================================================

/* ===== CASE (measured, assembled, as mounted) ===== */
case_w = 108;    // horizontal width against the wall
case_h = 70;     // vertical height as mounted
case_d = 35.5;   // depth out from the wall (thickness)
case_chamfer = 3;// the case's own 45-deg bottom-edge chamfer (MEASURE; drives inside fillets)
fit    = 0.6;    // clearance around the case in the cradle

/* ===== BACK PLATE ===== */
plate_th   = 4;    // plate thickness
top_margin = 16;   // plate strip above the case (carries the top screws)
side_clear = 1;    // clearance each side of the case

/* ===== CRADLE ===== */
floor_th      = 4;    // bottom shelf thickness
front_lip_th  = 3;    // front lip thickness
front_lip_h   = 18;   // front lip height above the floor
front_lip_w   = 91;   // front lip WIDTH (< case_w, to clear a case protrusion)
back_lip_th   = 3;    // back lip thickness
back_lip_h    = 5;    // back lip height above the floor

/* ===== WOOD SCREWS (countersunk; 1" #8 into ~1.5" board) ===== */
screw_shank_d = 4.5;
head_d        = 9.0;
cs_angle      = 82;    // US flat-head taper
screw_inset   = 14;    // top screws in from the side edges
screw_low_z   = 14;    // height of the extra low-center screw (behind the Pi)

show_case_ghost = true;
$fn = 64;

/* ===== derived Y stations (out from wall) ===== */
bw   = case_w + 2*side_clear;          // bracket width
ybl0 = plate_th;                       // back lip inner = plate front
ybl1 = plate_th + back_lip_th;
yc0  = ybl1;                           // case back
yc1  = yc0 + case_d;                   // case front
yfl0 = yc1 + fit;                      // front lip inner
yfl1 = yfl0 + front_lip_th;            // front lip outer
/* ===== Z stations ===== */
plate_h = floor_th + case_h + top_margin;
cs_depth = (head_d - screw_shank_d)/2 / tan(cs_angle/2);
screw_z_top = plate_h - top_margin/2;

module box(x_w, y0, y1, z0, z1) translate([-x_w/2, y0, z0]) cube([x_w, y1-y0, z1-z0]);

// 45-deg fillet in a concave corner at (yc,zc). dir=+1 ramp opens toward +Y, -1 toward -Y.
module fillet(yc, zc, size, width, dir)
    translate([-width/2, 0, 0]) rotate([90,0,90]) linear_extrude(width)
        polygon([[yc,zc], [yc + dir*size, zc], [yc, zc+size]]);

module cs_hole(x, z) translate([x, 0, z]) rotate([-90,0,0]) {
    translate([0,0,-1]) cylinder(d=screw_shank_d, h=plate_th+2);
    translate([0,0,plate_th-cs_depth]) cylinder(d1=screw_shank_d, d2=head_d+0.4, h=cs_depth+0.2);
}

difference() {
    union() {
        box(bw, 0,    plate_th, 0, plate_h);                    // back plate
        box(bw, plate_th, yfl1, 0, floor_th);                  // floor
        box(bw, ybl0, ybl1, 0, floor_th + back_lip_h);         // back lip (full width)
        box(front_lip_w, yfl0, yfl1, 0, floor_th + front_lip_h); // front lip (91mm)
        // inside fillets to mate the case's bottom chamfers
        fillet(yc0, floor_th, case_chamfer, bw,          +1);  // back-bottom
        fillet(yc1, floor_th, case_chamfer, front_lip_w, -1);  // front-bottom
    }
    cs_hole(-(bw/2 - screw_inset), screw_z_top);
    cs_hole( (bw/2 - screw_inset), screw_z_top);
    cs_hole(0, screw_low_z);                                    // extra low-center
}

if (show_case_ghost)
    %translate([-case_w/2, yc0, floor_th]) cube([case_w, case_d, case_h]);
