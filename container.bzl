load("@aspect_rules_js//js:defs.bzl", "js_image_layer")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_image_index", "oci_push", "oci_tarball")

def nodejs_container(
        name,
        image_name,
        registry,
        binary,
        cmd,
        tag_latest = True,
        visibility = None,
        **kwargs):
    """Generates rules to build NodeJS OCI (container) images.

    The rule named `name` will allow building an `oci_image_index` with the
    final container content for all platforms.

    There are also two other useful executable rules generated:
     * `package_<name>`, which exports the image to the Docker runtime on the
         current host;
     * `push_<name>`, which pushes the multi-arch OCI image to the remote
         registry.

    Args:
      name: the rule's name, typically `app`
      image_name: the name of the image to build, will be the tagged image's name
      registry: the registry URL to push to
      binary: the label of the js_binary target to include in the container
      cmd: the command to run inside the container
      tag_latest: whether to tag the image with the `latest` tag
      visibility: the visibility of the final rules
      **kwargs: additional arguments to pass to `oci_image`
    """
    js_image_layer(
        name = "%s-image-layers" % name,
        binary = binary,
        root = "/app",
        visibility = ["//visibility:private"],
    )

    oci_image(
        name = "%s-image" % name,
        base = "@ubuntu_latest",
        cmd = cmd,
        entrypoint = ["bash"],
        tars = [":%s-image-layers" % name],
        visibility = visibility,
        workdir = "/app",
        **kwargs
    )

    native.platform(
        name = "linux_amd64",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        visibility = ["//visibility:private"],
    )

    native.platform(
        name = "linux_arm64",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        visibility = ["//visibility:private"],
    )

    platform_transition_filegroup(
        name = "%s-image_arm64" % name,
        srcs = [":%s-image" % name],
        target_platform = ":linux_arm64",
        visibility = ["//visibility:private"],
    )

    platform_transition_filegroup(
        name = "%s-image_amd64" % name,
        srcs = [":%s-image" % name],
        target_platform = ":linux_amd64",
        visibility = ["//visibility:private"],
    )

    oci_image_index(
        name = name,
        images = [
            ":%s-image_arm64" % name,
            ":%s-image_amd64" % name,
        ],
        visibility = visibility,
    )

    oci_tarball(
        name = "package_%s" % name,
        image = select({
            "@platforms//cpu:arm64": ":%s-image_arm64" % name,
            "@platforms//cpu:x86_64": ":%s-image_amd64" % name,
        }),
        repo_tags = [image_name + ":latest"],
        visibility = visibility,
    )

    oci_push(
        name = "push_%s" % name,
        image = ":%s" % name,
        remote_tags = ["latest"] if tag_latest else None,
        repository = registry + ("" if registry[-1] == "/" else "/") + image_name,
    )
