# aspect-rules_oci

Minimal repro for an issue I'm seeing with `rules_oci`.

 * If I build on an **arm64 macOS host** and `bazel run //:push_app -- --tag macos_arm64`, I'm able to `docker run <image>:macos_arm64` on both `arm64` and `x86_64` hosts.
 * If I build on an **x86_64 macOS host** and `bazel run //:push_app -- --tag macos_x84_64`, I'm also able to `docker run <image>:macos_x86_64` on both `arm64` and `x86_64` hosts.
 * If I build on an **x86_64 linux host** (say from inside the [`build-container`](./build-container)) and `bazel run //:push_app -- --tag ubuntu_x86_64`, then I'm able to `docker run <image>:ubuntu_x86_64` on an `x86_64` host, but on an `arm64` host, I get an error message when running the container:
   ```
   $ docker run --rm -it <image>:ubuntu_x86_64
   qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory
   ```
