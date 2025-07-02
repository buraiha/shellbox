> 🇯🇵 日本語版はこちら: [README.md](./README.md)

# About ShellBox

![ShellBox\_Logo](./ShellBox_Logo_Title.png)

**"ShellBox doesn’t protect your host. You do."**

For those who are overly cautious about keeping their host OS pristine.

ShellBox is a framework that relentlessly pursues the goal of "executing commands without polluting the host OS."

Rather than just a tool, it is a mindset, a concept, and a commitment to mental hygiene.

**"Protect the mental and system health of both human and machine — ShellBox."**

---

## Everything in a Container

We just don’t want to dirty our host environment.

When developing on macOS, tools are often installed via Homebrew or MacPorts. But due to a past incident that wrecked our environment, we now prioritize environmental cleanliness above all.

For instance, attempting to install Azure CLI via MacPorts may result in an unusable mess, eventually forcing you to install Homebrew anyway. Though technically both can coexist, it just *feels* wrong. You know what we mean, right?

With Docker or Podman, commands can be executed without contaminating the host system — a great relief for mental well-being.

---

## How ShellBox Works

ShellBox encapsulates command execution in a containerized unit.

* A dedicated container image is created per command
* The local working directory is mounted to `/mnt`
* `podman run` is used to manipulate host data from the container

This enables tool reuse and sharing without compromising the host environment.

---

## 🧱 ENTRYPOINT is Everything

The only principle of ShellBox is: **define an ENTRYPOINT**.

As long as your command is ultimately specified as an `ENTRYPOINT` and acts as the operational root of your container, ShellBox doesn't care how you set it up.

Python scripts, Go binaries, statically linked C programs, Node.js CLI tools, or even environments built with Ansible—
they all work as long as there's an `ENTRYPOINT`.

ShellBox is a "one-command environment bootloader" and doesn’t interfere with how that environment is built.

---

## Recommended Container Runtime

We recommend **Podman**. Docker works too, but we just *like* Podman more. Also, the logo has a selkie in it.

Podman runs rootless by default, which is a big plus for security (yes, Docker can do it too these days).
Since ShellBox encapsulates many small tools, even a dangerous `rm -rf` becomes harmless in this model.

However, migrating from Docker to Podman rootless can be trickier than expected — be warned.

---

### Default Base Image

For a balance between practicality and purity, ShellBox uses [distroless](https://github.com/GoogleContainerTools/distroless?tab=readme-ov-file#what-images-are-available), specifically:

```
gcr.io/distroless/base-debian12:debug-nonroot
```

This image includes minimal utilities (`ls`, `cat`, etc.) and:

* Runs as non-root
* Has minimal packages
* Offers enhanced security

It’s the closest match to ShellBox’s philosophy.

---

## Dockerfile Examples

### Basic Command (e.g., `ls`)

```Dockerfile
FROM gcr.io/distroless/base-debian12:debug-nonroot
ENTRYPOINT ["ls"]
```

```sh
podman build -t shellbox_ls .
podman run --rm -v "$PWD":/mnt shellbox_ls /mnt
```

### Python Script

```Dockerfile
FROM gcr.io/distroless/python3-debian12:debug-nonroot
ENTRYPOINT ["python3"]
```

```python
# test_script.py
print("Hello, ShellBox!")
```

```sh
podman build -t shellbox_python .
podman run --rm -v "$PWD":/mnt shellbox_python /mnt/test_script.py
```

---

## How to Use ShellBox

### Install

```sh
curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/lib/setup.sh | bash
```

For reinstalling:

```sh
curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/lib/setup.sh | bash -s -- --force
```

### Uninstall

```sh
curl -sSL https://raw.githubusercontent.com/buraiha/shellbox/main/lib/teardown.sh | bash 
```

---

## 🧪 ShellBox Core Commands

`shellbox` is the CLI to manage the ShellBox environment:

| Command                                              | Description                         | Example                      | Notes                                 |                              |
| ---------------------------------------------------- | ----------------------------------- | ---------------------------- | ------------------------------------- | ---------------------------- |
| `shellbox init`                                      | Initializes the directory structure | `shellbox init`              | Run once during setup                 |                              |
| \`shellbox install <name> <entrypoint> \[image] \[-f | --force]\`                          | Installs a ShellBox command  | `shellbox install sb-ls ls`           | Defaults to distroless image |
| `shellbox rebuild <name> [--force]`                  | Rebuilds image and script           | `shellbox rebuild sb-ls`     | `--force` overwrites existing script  |                              |
| `shellbox uninstall`                                 | Uninstalls ShellBox command         | `shellbox uninstall`         | Deletes Dockerfile, script, and image |                              |
| `shellbox -e <name>`                                 | Edit script using `$EDITOR` or `vi` | `shellbox -e sb-ls`          | Uses `vi` if `$EDITOR` is unset       |                              |
| `shellbox -l`                                        | Lists installed commands            | `shellbox -l`                | Shows files under `bin`               |                              |
| `shellbox -r <name>`                                 | Removes a specific command          | `shellbox -r sb-ls`          | Deletes both script and container dir |                              |
| `shellbox --path`                                    | Displays directory layout           | `shellbox --path`            | Shows absolute paths                  |                              |
| `shellbox --version`                                 | Displays version info               | `shellbox --version`         | Reads `VERSION` file                  |                              |
| `shellbox edit-mounts <name>`                        | Edit `mounts.conf` for a command    | `shellbox edit-mounts sb-ls` | Auto-generates on first run           |                              |

---

## 🧭 /mnt as Logical Workspace

In ShellBox, the host’s working directory (usually `$PWD`) is mounted to `/mnt` inside the container.

This is more than convenience—it's a **conceptual workspace** in ShellBox.

* Avoids polluting host environment
* Ensures clarity and scoping
* Improves portability of scripts

---

## 🧩 Custom Mount Definitions (`mounts.conf`)

To define additional mounts for specific commands:

```text
/usr/local/shellbox/containers/<command>/mounts.conf
```

Format:

* One mount per line (in `-v` style: `local:container[:mode]`)
* Supports comments (`#`) and blank lines
* Example:

```text
/home/takashi/.ssh:/root/.ssh:ro
/tmp/output:/out
```

---

## 🧰 Template System

ShellBox uses `/usr/local/shellbox/bin/runsh_template.sh` to generate execution scripts (called **ShellBox scripts**) per command.

By default, the scripts pass all arguments (`$@`) directly to `podman run` without modification, ensuring compatibility with diverse tools.

If needed, customize the template or each command's script.

---

### 🔸 When Customization Is Needed

| Example                        | Reason                                                |
| ------------------------------ | ----------------------------------------------------- |
| `jq`                           | Requires stdin. Add `-i` to enable input.             |
| `openssl req -new`             | Requires interactive input. Use `-it` for pseudo-TTY. |
| `convert input.png output.jpg` | Assumes input files under `/mnt`. Adjust accordingly. |

---

### 💡 About stdin

By default, ShellBox scripts **do not** include `-i` (interactive stdin).

Example of a case that won't work out of the box:

```sh
echo '{"foo": 1}' | my_jq '.foo'  # ❌
```

To fix it, customize the script:

```sh
#!/bin/sh
CMD_IMAGE="{{CMD_IMAGE}}"

podman run --rm -i -v "$PWD":/mnt "$CMD_IMAGE" "$@"
```

For interactive commands:

```sh
#!/bin/sh
CMD_IMAGE="{{CMD_IMAGE}}"

podman run --rm -it -v "$PWD":/mnt "$CMD_IMAGE" "$@"
```

---

## 📌 Usage Guidelines

* Typical commands (like `ls`, `python`, `grep`) work as-is
* Customize the script or Dockerfile when dealing with complex I/O
* ShellBox does not parse arguments or output — modularity is key

> **Note:** ShellBox is *not* for interactive container sessions
> For that, use `podman run -it` or `docker exec` instead

---

### ❗ About `sudo`: A Double-Edged Sword

You *can* work around issues using `sudo podman run`,
but it violates ShellBox's core philosophy — host protection.

Still, if needed, you can use `--root` when installing ShellBox commands.

---

## 💬 About WSL Support

ShellBox was previously considered incompatible with WSL due to user misjudgment.
It now works well under modern WSL2.

However, some mount/TTY quirks may remain — use at your own risk.

---

## 🔮 Planned Features

* `socat` proxy to host serial ports
* Multi-stage builds for lightweight static binaries
* **QEMU-based isolated OS-level execution** (see [`issue4_qemu`](https://github.com/buraiha/shellbox/tree/issue4_qemu))

---

## Finally

ShellBox is a focused execution capsule designed to protect your host.

Use it to preserve your sanity as a developer.

Pull requests with unique ideas or clever uses are welcome —
but we'll review them strictly based on ShellBox’s philosophy.

---

必要に応じて Markdown ファイルとしてお渡しすることも可能です。どうしますか？
