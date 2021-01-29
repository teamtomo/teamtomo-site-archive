# `dtmslice` viewing controls

`dtmslice` is a 3D tomogram viewer with many powerful annotation tools - 
see the documentation [here](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Dtmslice).

This document explains the basics of visualising a tomogram in `dtmslice`

## Overview
`dtmslice` depicts a 2D slice of a 3D volume at its position within the 3D volume.

![dtmslice overview](dtmslice-controls.assets/overview.png)

Important parameters of the slice are 
- the `position` of the slice
- the `thickness` of the slice
- the projection direction of the slice
- the `opacity` of the slice

## Viewing controls
```{tabbed} general
Some parameters can be controlled from the `Shown slice` controls on the left hand side of `dtmslice`

![shown slice controls](dtmslice-controls.assets/shown-slice.png)
```

```{tabbed} moving a slice
A slice can be moved along it's projection direction by `left-click` + dragging the mouse
or using the mouse wheel.

![moving a slice](dtmslice-controls.assets/move-slice.gif)
```

```{tabbed} projection direction
The projection direction can easily be changed between 
'x', 'y' or 'z' by hitting the `x`, `y` or `z` keys with your mouse on the slice. 
Mouse position controls the new position of the slice.

![xyz-projection](dtmslice-controls.assets/xyzproj.gif)
```

```{tabbed} scene perspective
You can move the camera around the scene by `ctrl` + `left-click` + dragging the mouse.

![move camera](dtmslice-controls.assets/move-camera.gif)
```

```{tabbed} saving slices
You can save a copy of the active slice in `dtmslice` by hitting the `s` key.

![save slice](dtmslice-controls.assets/save-slice.gif)
```

```{tabbed} slice thickness
A `thickness` of 10 means that the displayed slice will be an average over 10 slices 
along the projection direction.
```
