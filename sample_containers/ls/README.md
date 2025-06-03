# ShellBox ls

lsするだけですが何か?

## Instructions

```sh
podman build -t box_ls .
podman run --rm -v $PWD:/mnt box_ls /mnt
```
