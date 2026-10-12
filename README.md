# Parametric SKÅDIS Flat Mount

An OpenSCAD model of a flat plate that hangs on an IKEA SKÅDIS pegboard, with a smooth front face for double-sided tape.

## Parameters

Open `skadis_flat_mount.scad` in OpenSCAD and use the Customizer:

| Parameter     | Description                      | Range       |
|---------------|----------------------------------|-------------|
| `face_width`  | Width of the tape face (mm)      | 20–400      |
| `face_height` | Height of the tape face (mm)     | 20–400      |
| `face_depth`  | Thickness of the face plate (mm) | 2–15        |

The number of hooks is worked out from the face size. Hooks go in every SKÅDIS slot in the top and bottom rows that fits behind the plate, centred on the plate. The top hooks carry the load and the bottom hooks stop the plate from swinging. The hook count is printed to the console.

## Printing

The model is already in print orientation: tape face down, hooks pointing up. Each hook's lip overhangs about 5.5 mm. Most printers handle this, but enable supports touching the build plate if yours sags.

## Mounting

Push all the hooks straight into the slots, then slide the plate down about 5 mm until it locks.

## Fit tuning

The hook width (`tab_w`, 4.4 mm) and board gap (`gap`, 5.4 mm) are in the hidden section of the file if the fit on your board is too tight or loose.
