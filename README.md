
# JUnit Annotate Buildkite Plugin [![Build status](https://badge.buildkite.com/e57701b1037f2c77d0b3f2e4901559ed2e8f131119cd7806ad.svg?branch=master)](https://buildkite.com/buildkite/plugins-junit-annotate)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that parses junit.xml artifacts (generated across any number of parallel steps) and creates a [build annotation](https://buildkite.com/docs/agent/v3/cli-annotate) listing the individual tests that failed.

## Example

The following pipeline will run `test.sh` jobs in parallel, and then process all the resulting JUnit XML files to create a summary build annotation.

```yml
steps:
  - command: test.sh
    parallelism: 50
    artifact_paths: tmp/junit-*.xml
  - wait: ~
    continue_on_failure: true
  - plugins:
      - junit-annotate#v2.4.1:
          artifacts: tmp/junit-*.xml
```

## Configuration

### `artifacts` (required)

The artifact glob path to find the JUnit XML files.

Example: `tmp/junit-*.xml`

### `always-annotate` (optional, boolean)

Forces the creation of the annotation even when no failures or errors are found

### `context` (optional)

Default: `junit`

The buildkite annotation context to use. Useful to differentiate multiple runs of this plugin in a single pipeline.

### `job-uuid-file-pattern` (optional)

Default: `-(.*).xml`

The regular expression (with capture group) that matches the job UUID in the junit file names. This is used to create the job links in the annotation. 

To use this, configure your test reporter to embed the `$BUILDKITE_JOB_ID` environment variable into your junit file names. For example `"junit-buildkite-job-$BUILDKITE_JOB_ID.xml"`.

### `failure-format` (optional)

This setting controls the format of your failed test in the main annotation summary.

There are two options for this:
* `classname` (the default)
  * displays: `MyClass::UnderTest text of the failed expectation in path.to.my_class.under_test`
* `file`
  * displays: `MyClass::UnderTest text of the failed expectation in path/to/my_class/under_test.file_ext`

### `fail-build-on-error` (optional)  

Default: `false`

If this setting is true and any errors are found in the JUnit XML files during parsing, the annotation step will exit with a non-zero value, which should cause the build to fail.
