
#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# Uncomment to get debug output from each stub
# export MKTEMP_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
# export DOCKER_STUB_DEBUG=/dev/tty
# export DU_STUB_DEBUG=/dev/tty

export artifacts_tmp="tests/tmp/junit-artifacts"
export annotation_tmp="tests/tmp/junit-annotation"
export annotation_input="tests/tmp/annotation.input"

@test "runs the annotator and creates the annotation" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_FAIL_BUILD_ON_ERROR=false

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4" \
    "annotate --context \* --style \* : cat >'${annotation_input}'; echo Annotation added with context \$3 and style \$5, content saved"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env \* --env \* \* ruby /src/bin/annotate /junits : echo '<details>Failure</details>' && exit 64"

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "Annotation added with context junit and style error"
  assert_equal "$(cat "${annotation_input}")" '<details>Failure</details>'

  unstub mktemp
  unstub buildkite-agent
  unstub docker
  rm "${annotation_input}"
}

@test "can define a special context" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_CONTEXT="junit_custom_context"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4" \
    "annotate --context \* --style \* : cat >'${annotation_input}'; echo Annotation added with context \$3 and style \$5, content saved"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env \* --env \* \* ruby /src/bin/annotate /junits : cat tests/2-tests-1-failure.output && exit 64"

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "Annotation added with context junit_custom_context"
  
  unstub mktemp
  unstub buildkite-agent
  unstub docker
  rm "${annotation_input}"
}

@test "can pass through optional job uuid file pattern" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_JOB_UUID_FILE_PATTERN="custom_(*)_pattern.xml"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4" \
    "annotate --context \* --style \* : cat >'${annotation_input}'; echo Annotation added with context \$3 and style \$5, content saved"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env BUILDKITE_PLUGIN_JUNIT_ANNOTATE_JOB_UUID_FILE_PATTERN='custom_(*)_pattern.xml' --env \* --env \* \* ruby /src/bin/annotate /junits : cat tests/2-tests-1-failure.output && exit 64"

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "Annotation added"

  unstub mktemp
  unstub buildkite-agent
  unstub docker
  rm "${annotation_input}"
}

@test "can pass through optional failure format" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_FAILURE_FORMAT="file"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4" \
    "annotate --context \* --style \* : cat >'${annotation_input}'; echo Annotation added with context \$3 and style \$5, content saved"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env BUILDKITE_PLUGIN_JUNIT_ANNOTATE_FAILURE_FORMAT='file' --env \* \* ruby /src/bin/annotate /junits : cat tests/2-tests-1-failure.output && exit 64"

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "Annotation added"

  unstub mktemp
  unstub buildkite-agent
  unstub docker
  rm "${annotation_input}"
}

@test "doesn't create annotation unless there's failures" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env \* --env \* \* ruby /src/bin/annotate /junits : echo 'Total tests: 0'"

  run "$PWD/hooks/command"

  assert_success

  unstub mktemp
  unstub buildkite-agent
  unstub docker
}

@test "creates annotation with no failures but always annotate" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ALWAYS_ANNOTATE=1

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4" \
    "annotate --context \* --style \* : cat >'${annotation_input}'; echo Annotation added with context \$3 and style \$5, content saved"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env \* --env \* \* ruby /src/bin/annotate /junits : echo 'Total tests: 0'"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Total tests: 0"
  assert_output --partial "Will create annotation anyways"
  assert_equal "$(cat "${annotation_input}")" 'Total tests: 0'

  unstub mktemp
  unstub buildkite-agent
  unstub docker
}

@test "errors without the 'artifacts' property set" {
  run "$PWD/hooks/command"

  assert_failure

  assert_output --partial "Missing artifacts configuration for the plugin"
  refute_output --partial ":junit:"
}

@test "fails if the annotation is larger than 1MB even after summary" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  # 1KB over the 1MB size limit of annotations
  stub du \
    "-k \* : echo 1025$'\t'\$2" \
    "-k \* : echo 1025$'\t'\$2"

  stub buildkite-agent \
    "artifact download \* \* : echo Downloaded artifact \$3 to \$4"

  stub docker \
    "--log-level error run --rm --volume \* --volume \* --env \* --env \* --env \* \* ruby /src/bin/annotate /junits : cat tests/2-tests-1-failure.output && exit 64"

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "Failures too large to annotate"
  assert_output --partial "failures are too large to create a build annotation"

  unstub docker
  unstub du
  unstub buildkite-agent
  unstub mktemp
}

@test "creates summary annotation if original is larger than 1MB" {
  export BUILDKITE_PLUGIN_JUNIT_ANNOTATE_ARTIFACTS="junits/*.xml"

  stub mktemp \
    "-d \* : mkdir -p '$artifacts_tmp'; echo '$artifacts_tmp'" \
    "-d \* : mkdir -p '$annotation_tmp'; echo '$annotation_tmp'"

  # 1KB over the 1MB size limit of annotations
  stub du \
    "-k \* : echo 1025$'\t'\$2" \
    "-k \* : echo 10$'\t'\$2"

  stub buildkite-agent \