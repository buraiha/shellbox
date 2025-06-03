# ShellBox

![ShellBox_Logo](./ShellBox_Logo_Title.png)

> **Protecting your host isn't ShellBox. It's you.**  
> **For the purity and health of both human and machine. ShellBox.**

ShellBox is dedicated to those who are fanatical about keeping their host OS clean.

It’s a system that pursues one simple principle:  
**How can we issue commands without polluting the host OS environment?**

ShellBox is not just a tool—it's a mindset, a concept, a way of life.  
It's a hygienic discipline for your mental well-being as well as your machine.

---

## 🧼 Everything Inside a Container

I’m obsessive about not contaminating my host OS.

As a daily macOS user, I’ve long relied on MacPorts or Homebrew to install third-party tools. But one misstep wrecked my entire environment years ago. Since then, I’ve sworn by host system purity.

Just recently, I tried installing Azure CLI via MacPorts.  
It was listed, yes—but didn’t work properly.  
In the end, I reluctantly installed Homebrew too. They can coexist, sure, but... it just feels wrong. You get me?

With Docker or Podman, I can run commands without affecting my host. It’s incredibly soothing—mentally and technically.

---

## 🧰 What Is ShellBox?

ShellBox encapsulates your commands, config, dependencies, and assumptions into a **reusable shell unit**.

The idea is simple:

1. Use a container to wrap the command you want to run
2. Mount your local directory into the container
3. Run the command **inside** the container

If the command needs to modify the local directory, simply mount it.  
That's it.

Here’s an example with `ls`: see [Dockerfile Example](#dockerfile-example) below.  
The Dockerfile’s `ENTRYPOINT` will be executed, so you can run encapsulated binaries with arguments via `run`.

---

## 🏃 Recommended Container Runtime

I recommend **Podman**. Docker is fine too, but I just prefer Podman.

- It runs **rootless** out of the box, which is safer (though Docker can too).
- Since ShellBox will containerize many small tools, it's good to know an accidental `rm -rf` won't nuke your system.

Also... let's be real. The Podman logo has a **key in a shell**. That’s ShellBox.

---

## 🪶 Recommended Base Image

**Distroless** is great for minimal image size.

Be aware:
- Only images with the `debug` tag include busybox.
- If you need basic commands like `cat` or `ls`, you’ll need a debug version.

There are flavors with Python, Java, and more—use what suits your need.

- [List of Available Distroless Images](https://github.com/GoogleContainerTools/distroless?tab=readme-ov-file#what-images-are-available)

Use `nonroot` tag if you want better security.

---

## 📦 Dockerfile Example: Basic Commands (ls, cat, etc.)

```Dockerfile
# Base image
FROM gcr.io/distroless/base-debian12:debug-nonroot
ENTRYPOINT ["ls"]
```

ShellBox Execution:

```sh
# Build the image
podman build -t shellbox_ls .

# Run the container
podman run --rm -v $PWD:/mnt shellbox_ls /mnt
```

---

## 🐍 Dockerfile Example: Python Environment

```Dockerfile
# Base image
FROM gcr.io/distroless/python3-debian12:debug-nonroot

# Install extra packages if needed

# Set entrypoint
ENTRYPOINT ["python3"]
```

`test_script.py`:

```python
print("Hello, ShellBox!")
```

Run ShellBox:

```sh
podman build -t shellbox_python .
podman run --rm -v $PWD:/mnt shellbox_python /mnt/test_script.py
```

---

## 📈 Future Plans

- Deploy command wrappers to `/usr/local/shellbox/bin` that run `podman run` internally
- Once included in `PATH`, ShellBox commands become globally executable
- Create an install system to auto-deploy these wrappers
