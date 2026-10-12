// Parametric flat IKEA SKÅDIS mount for double-sided tape.
//
// The front face (z = 0) is the flat tape surface; hooks project from the
// back. Hook count and placement are inferred from the face size: every
// SKÅDIS slot position in the top and bottom rows that fits behind the face
// gets a hook, with the pattern centered on the plate.
//
// Model is already in print orientation: tape face down on the bed.
// Mount by pushing all hooks straight into the slots, then sliding down.

/* [Mount Face] */
// Width of the flat tape face (mm)
face_width = 60; // [20:1:400]
// Height of the flat tape face (mm)
face_height = 60; // [20:1:400]
// Thickness of the face plate (mm)
face_depth = 4; // [2:0.5:15]

/* [Printing] */
// Add breakaway supports under each hook lip
supports = false;

/* [Hidden] */
$fn = 32;

// SKÅDIS board: 5 x 15 mm slots on a staggered lattice. Slots in the same
// row are 40 mm apart; adjacent rows are 20 mm apart, offset 20 mm sideways.
slot_h = 15;
row_pitch = 20;
col_pitch = 40;
board_t = 5;

// Hook geometry. tab_h + lip_h must stay under slot_h so the hook passes
// straight through the slot before dropping into place.
tab_w = 4.4;            // across the 5 mm slot width
tab_h = 7.5;            // tab height resting on the slot's bottom edge
lip_h = 5.5;            // how far the lip hangs below the slot behind the board
lip_t = 4.5;            // lip thickness
lip_catch = 3;          // flat part of the lip that bears on the board; the
                        // rest slopes at 45° so it prints without support
gap = board_t + 0.4;    // space for the board between plate and lip
margin = 2;             // keep tabs this far inside the plate edges
corner_r = 2;

// Breakaway supports under each hook lip: thin fins rising from the plate,
// stopping one layer short of the lip so they snap off cleanly.
sup_fin_t = 0.8;        // fin thickness
sup_pitch = 2;          // fin spacing (the lip bridges between fins)
sup_z_gap = 0.2;        // air gap under the lip (about one layer)
sup_xy_gap = 0.6;       // clearance from the tab

W = face_width;
H = face_height;
T = face_depth;

// --- Rows (vertical) --------------------------------------------------------
// yb = y of a tab's bottom face (= the slot's bottom edge when hung).
y_span = H - 2 * margin - tab_h;
n_rows = y_span < 0 ? 0 : floor(y_span / row_pitch) + 1;
row_dist = row_pitch * (n_rows - 1);              // top row to bottom row
yb_bottom = margin + (y_span - row_dist) / 2;
yb_top = yb_bottom + row_dist;
stagger = (n_rows - 1) % 2 == 1 ? row_pitch : 0;  // odd row count apart => offset

// --- Columns (horizontal) ---------------------------------------------------
x_lo = margin + tab_w / 2;
x_hi = W - margin - tab_w / 2;

function row_xs(phase) =
    let(start = phase - col_pitch * floor((phase - x_lo) / col_pitch))
    [for (x = [start : col_pitch : x_hi + 1e-6]) x];

function layout(p) =
    let(top = row_xs(p),
        bot = n_rows > 1 ? row_xs(p + stagger) : [],
        all = concat(top, bot),
        ctr = len(all) ? (min(all) + max(all)) / 2 : W / 2)
    [len(all) * 1000 - abs(ctr - W / 2), top, bot];

// Slide the lattice across one column pitch; keep the phase with the most
// hooks, breaking ties by how well the pattern is centered.
candidates = [for (p = [x_lo : 0.25 : x_lo + col_pitch - 0.01]) layout(p)];
best = [for (c = candidates) if (c[0] == max([for (d = candidates) d[0]])) c][0];
top_xs = best[1];
bot_xs = best[2];

assert(n_rows > 0 && len(top_xs) > 0,
       "Face is too small to fit a SKÅDIS hook; increase width/height.");
assert(tab_h + lip_h < slot_h, "Hook too tall to pass through a slot.");

echo(str("SKÅDIS hooks: ", len(top_xs) + len(bot_xs),
         " (top row ", len(top_xs), ", bottom row ", len(bot_xs), ")"));

// --- Geometry ---------------------------------------------------------------
module plate()
    linear_extrude(T)
        offset(r = corner_r) offset(delta = -corner_r)
            square([W, H]);

// Hook profile drawn in (y, z), extruded along x.
module hook(xc, yb) {
    z1 = T + gap;
    z2 = z1 + lip_t;
    translate([xc - tab_w / 2, 0, 0])
        multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]])
            linear_extrude(tab_w)
                polygon([
                    [yb, T - 0.01],
                    [yb + tab_h + 1, T - 0.01],       // small root fillet
                    [yb + tab_h, T + 1],
                    [yb + tab_h, z2 - 1],
                    [yb + tab_h - 1, z2],
                    [yb - lip_h + 1.5, z2],           // lead-in chamfer
                    [yb - lip_h, z2 - 1.5],
                    [yb - lip_h, z1 + lip_h - lip_catch],  // 45° underside
                    [yb - lip_catch, z1],
                    [yb, z1],
                ]);
}

// Fins spanning the tab width, spaced under the flat part of the lip.
module lip_support(xc, yb) {
    h = gap - sup_z_gap;
    y_near = yb - sup_xy_gap - sup_fin_t;
    y_far = yb - lip_catch;   // only the flat part overhangs
    n = ceil((y_near - y_far) / sup_pitch) + 1;
    for (i = [0 : n - 1])
        let(y = y_near - i * (y_near - y_far) / (n - 1))
        translate([xc - tab_w / 2, y, T - 0.01])
            cube([tab_w, sup_fin_t, h + 0.01]);
}

module mount_hook(xc, yb) {
    hook(xc, yb);
    if (supports) lip_support(xc, yb);
}

plate();
for (x = top_xs) mount_hook(x, yb_top);
if (n_rows > 1) for (x = bot_xs) mount_hook(x, yb_bottom);
