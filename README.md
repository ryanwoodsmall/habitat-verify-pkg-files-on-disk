# verify-habitat-pkg-files-on-disk

verify on-disk files using Habitat's stored BLAKE2 sums.

this is a simple bash script that uses coreutils `b2sum` command.

equivalent to:

```
for f in /hab/pkgs/*/*/*/*/FILES ; do
  b2sum --quiet --check ${f} 2>/dev/null
done
```

with a lot of boilerplate.

## links

- bldr : https://bldr.habitat.sh/#/pkgs/ryanwoodsmall/verify-habitat-pkg-files-on-disk
