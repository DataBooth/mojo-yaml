"""Real-world YAML fixtures.

These tests encode the current expectations for the v0.1.0 "Lite" subset:
- yaml_lite_example.yaml: MUST parse successfully (designed for this parser).
- pre_commit.yaml: MAY fail today (flow-style list); we assert a failure so any
  unexpected success will be visible.
- github_workflow.yaml: MUST fail (heavily uses flow-style and expressions).
- docker_compose.yaml: MAY fail (single quotes, mixed styles); again we assert
  that it currently fails so changes are deliberate.
"""

from pathlib import Path
from testing import assert_true, TestSuite
from yaml import parse


fn test_yaml_lite_example_parses() raises:
    """YAML_lite_example.yaml should parse and produce a mapping."""
    var p = Path("fixtures/yaml_lite_example.yaml")
    var content = p.read_text()

    var result = parse(content)
    assert_true(result.is_mapping())
    # Sanity check a couple of keys so structure stays stable
    assert_true("name" in result.mapping_value)
    assert_true("server" in result.mapping_value)


fn test_pre_commit_expected_failure() raises:
    """Pre-commit.yaml currently fails due to flow-style list; assert failure."""
    var p = Path("fixtures/pre_commit.yaml")
    var content = p.read_text()

    var failed = False
    try:
        var _ = parse(content)
    except e:
        failed = True
        print("pre_commit.yaml failed as expected:", e)

    if not failed:
        raise Error("Expected parse failure for pre_commit.yaml (flow-style list)")


fn test_github_workflow_expected_failure() raises:
    """GitHub_workflow.yaml is outside the Lite subset; MUST fail for now."""
    var p = Path("fixtures/github_workflow.yaml")
    var content = p.read_text()

    var failed = False
    try:
        var _ = parse(content)
    except e:
        failed = True
        print("github_workflow.yaml failed as expected:", e)

    if not failed:
        raise Error("Expected parse failure for github_workflow.yaml (flow-style + expressions)")


fn test_docker_compose_expected_failure() raises:
    """Docker_compose.yaml currently fails (quotes, mixed styles); assert failure."""
    var p = Path("fixtures/docker_compose.yaml")
    var content = p.read_text()

    var failed = False
    try:
        var _ = parse(content)
    except e:
        failed = True
        print("docker_compose.yaml failed as expected:", e)

    if not failed:
        raise Error("Expected parse failure for docker_compose.yaml in v0.1.0 Lite")


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
