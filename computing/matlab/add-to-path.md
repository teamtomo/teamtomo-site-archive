# Adding scripts/functions to your PATH in `MATLAB`

The `PATH` variable contains a list of paths (directories on your system). This list of paths will be searched, in order, whenever you call a function or a script by name.

If a file you want to run is not in a directory in your `PATH` variable, `MATLAB` will not know where to look for it.

To add a directory to the `PATH`, use `addpath()` as follows

```matlab
addpath('/directory/containing/my/script')
```

```{warning}
While scripts can have any name, functions in `MATLAB` must have the same name as the file in which they are contained.

e.g. for the function `my_function()` to be available it must be in a file called `my_function.m`.
```