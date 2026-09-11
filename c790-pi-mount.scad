// ============================================================================
// C790 (HDMI-to-CSI-2 capture, 30 x 45 mm PCB) -> Pi-case mounting tray
// Bolts to the case's 20 mm hole grid; stands the C790 off on 4 posts.
// Units: mm. Print flat (base on bed, posts up) -- no supports.
// ============================================================================

/* ========================= PARAMETERS ========================= */

// ---- C790 board ----
c790_w = 30;              // PCB width  (X)
c790_l = 45;              // PCB length (Y)
// Measured mounting-hole pattern (center-to-center). Board holes are 2.6 mm (M2.5).
c790_hole_dx = 23;        // hole spacing across the 30 mm WIDTH  (X)
c790_hole_dy = 30;        // hole spacing along  the 45 mm LENGTH (Y)
standoff_h   = 6;         // how high to lift the board off the base
standoff_od  = 5;         // post outer diameter (keeps clear of the fan holes)
board_screw_d = 2.2;      // hole in each post: 2.2 = self-tap M2.5; 2.7 = clearance for through-screw + nut
post_setback = 6;         // shift the posts (and board) toward a short edge (-Y); centered on the long edge. Flip sign for the other short edge.

// ---- Mount to the case-top FAN screw holes (4 holes in a square) ----
fan_pitch    = 32;        // fan hole spacing, on-center (40 mm fan = 32 mm; measure to confirm)
fan_screw_d  = 3.2;       // clearance for the fan screws (~M3)

// ---- Base plate ----
base_th     = 3;          // plate thickness
base_margin = 5;          // material around the widest feature
corner_r    = 3;          // corner radius
show_board_ghost = true;  // translucent PCB outline for visual check (not printed)

$fn = 64;
/* ============================================================== */


/* ------- derived geometry ------- */
hx = c790_hole_dx/2;                    // C790 hole X offset from center
hy = c790_hole_dy/2;                    // C790 hole Y offset from center
c790_holes = [[hx,hy],[-hx,hy],[hx,-hy],[-hx,-hy]];

// posts sit setback toward a short edge (-Y); no X offset keeps them centered on the long edge
post_holes = [ for (p = c790_holes) [p[0], p[1] - post_setback] ];

// fan mount holes: 4 in a square at fan_pitch on-center
fan_holes = [ for (sx=[-1,1], sy=[-1,1]) [sx*fan_pitch/2, sy*fan_pitch/2] ];

base_w = max(c790_w, fan_pitch) + 2*base_margin;
base_l = max(c790_l, fan_pitch) + 2*base_margin;


/* ------- helper modules ------- */
module rounded_square(w, l, r) {
    hull() for (sx=[-1,1], sy=[-1,1])
        translate([sx*(w/2-r), sy*(l/2-r)]) circle(r=r);
}


/* ------- the part ------- */
module tray() {
    difference() {
        union() {
            // base plate
            linear_extrude(base_th) rounded_square(base_w, base_l, corner_r);
            // C790 standoffs
            for (p = post_holes)
                translate([p[0], p[1], 0])
                    cylinder(d=standoff_od, h=base_th + standoff_h);
        }
        // fan-mount holes (through the base)
        for (p = fan_holes) translate([p[0], p[1], -0.5])
            cylinder(d=fan_screw_d, h=base_th + 1);
        // board screw holes (top-down into each post only)
        for (p = post_holes)
            translate([p[0], p[1], base_th])
                cylinder(d=board_screw_d, h=standoff_h + 1);
    }
}

tray();

// translucent ghost of the C790 sitting on the posts (visual only)
if (show_board_ghost)
    %translate([0, -post_setback, base_th + standoff_h])
        linear_extrude(1.2) square([c790_w, c790_l], center=true);
