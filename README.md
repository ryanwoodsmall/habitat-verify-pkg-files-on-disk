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

## install and use

```
# install the package:
sudo hab pkg install ryanwoodsmall/verify-habitat-pkg-files-on-disk

# an install hook creates a symlink but does not create a _real_ service

# verify all installedpackages:
sudo /hab/svc/verify-habitat-pkg-files-on-disk/static/bin/verify-habitat-pkg-files-on-disk.sh

# verify just (the latest version of) this package:
hab pkg list ryanwoodsmall/verify-habitat-pkg-files-on-disk \
| tail -1 \
| xargs /hab/svc/verify-habitat-pkg-files-on-disk/static/bin/verify-habitat-pkg-files-on-disk.sh
```

## links

- bldr : https://bldr.habitat.sh/#/pkgs/ryanwoodsmall/verify-habitat-pkg-files-on-disk
