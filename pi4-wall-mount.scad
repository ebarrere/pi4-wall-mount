// ============================================================================
// Raspberry Pi 4 case -> wall-mount cradle (ikea-type shelf side wall)
// Mounted pose: case flat against the wall, power/HDMI edge UP, dropped into a
// bottom cradle (floor + short front lip). Back plate screws to the shelf board
// with countersunk wood screws. 45-deg chamfers on the bottom edges match the
// case's bottom chamfers.
//
// Coords: X = horizontal (along wall), Y = out from wall, Z = up.
// Built as a chamfered Y-Z cross-section extruded along X. Units: mm.
// ============================================================================

/* ===== CASE (measured, assembled, as mounted) ===== */
case_w = 108;    // horizontal width against the wall
case_h = 70;     // vertical height as mounted
case_d = 35.5;   // depth out from the wall (thickness)
fit    = 0.6;    // clearance around the case in the cradle

/* ===== BACK PLATE ===== */
plate_th   = 4;    // plate thickness
top_margin = 16;   // plate strip above the case (carries the screws)
side_clear = 1;    // clearance each side of the case in the cradle

/* ===== CRADLE (the hook) ===== */
floor_th = 4;   // bottom shelf thickness
lip_th   = 3;   // front retaining lip thickness
lip_h    = 18;  // front lip height above the floor

/* ===== BOTTOM CHAMFER (match the case) ===== */
chamfer = 3;    // 45-deg chamfer on the bottom edges

/* ===== WOOD SCREWS (countersunk; 1" #8 into ~1.5" board) ===== */
screw_shank_d = 4.5;
head_d        = 9.0;
cs_angle      = 82;    // US flat-head taper
screw_inset   = 14;    // screw center in from the side edges

show_case_ghost = true;
$fn = 64;

/* ===== derived ===== */
cd = case_d + fit;                       // cradle inner depth
bw = case_w + 2*side_clear;              // bracket width (uniform)
y1 = plate_th;                           // plate front / case back
y2 = plate_th + cd;                      // case front / lip inner
y3 = plate_th + cd + lip_th;             // lip outer / front face
zf = floor_th;                           // floor top / case bottom
zl = floor_th + lip_h;                   // lip top
zp = floor_th + case_h + top_margin;     // plate top
cs_depth = (head_d - screw_shank_d)/2 / tan(cs_angle/2);
screw_z  = zp - top_margin/2;

// Y-Z profile of the bracket, bottom corners chamfered at 45 deg
profile = [
    [chamfer, 0], [y3 - chamfer, 0], [y3, chamfer],
    [y3, zl], [y2, zl], [y2, zf], [y1, zf], [y1, zp],
    [0, zp], [0, chamfer]
];

module countersunk_hole(x) {
    translate([x, 0, screw_z]) rotate([-90, 0, 0]) {
        translate([0, 0, -1]) cylinder(d=screw_shank_d, h=plate_th + 2);
        translate([0, 0, plate_th - cs_depth])
            cylinder(d1=screw_shank_d, d2=head_d + 0.4, h=cs_depth + 0.2);
    }
}

difference() {
    // extrude the chamfered profile across the bracket width
    translate([-bw/2, 0, 0]) rotate([90, 0, 90])
        linear_extrude(bw) polygon(profile);
    countersunk_hole(-(bw/2 - screw_inset));
    countersunk_hole( (bw/2 - screw_inset));
}

if (show_case_ghost)
    %translate([-case_w/2, plate_th, floor_th]) cube([case_w, case_d, case_h]);
