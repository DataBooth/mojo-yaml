"""
Test real-world YAML fixtures to understand what works and what doesn't.
This is a diagnostic tool to evaluate v0.1.0 Lite capabilities.
"""

from pathlib import Path
from yaml import parse


fn test_fixture(fixture_name: String, path: String) raises:
    """Test a single fixture and report results."""
    print("\n" + "="*60)
    print("Testing: " + fixture_name)
    print("="*60)
    
    var p = Path(path)
    var content = p.read_text()
    
    print("Content preview (first 200 chars):")
    print(content[:200] + "..." if len(content) > 200 else content)
    print()
    
    try:
        var result = parse(content)
        print("✅ PARSING SUCCEEDED")
        
        # Show structure type
        if result.is_mapping():
            print("Type: Mapping (dict) with", len(result.mapping_value), "keys")
        elif result.is_sequence():
            print("Type: Sequence (list) with", len(result.sequence_value), "items")
        else:
            print("Type: Scalar value")
        
        return
    except e:
        print("❌ PARSING FAILED")
        print("\nError:", e)
        return


fn main() raises:
    print("="*60)
    print("REAL-WORLD YAML FIXTURE TESTING")
    print("="*60)
    
    # Test 1: YAML Lite Example (should work - designed for this parser)
    test_fixture(
        "yaml_lite_example.yaml",
        "fixtures/yaml_lite_example.yaml"
    )
    
    # Test 2: Pre-commit config (block-style, should mostly work)
    test_fixture(
        "pre_commit.yaml",
        "fixtures/pre_commit.yaml"
    )
    
    # Test 3: GitHub workflow (has flow-style arrays, will fail)
    test_fixture(
        "github_workflow.yaml", 
        "fixtures/github_workflow.yaml"
    )
    
    # Test 4: Docker Compose (single quotes, empty values)
    test_fixture(
        "docker_compose.yaml",
        "fixtures/docker_compose.yaml"
    )
    
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print("Check results above to understand v0.1.0 Lite limitations")
