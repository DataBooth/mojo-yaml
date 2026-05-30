"""Tests for YAML value types."""

from testing import assert_equal, assert_true, assert_false, TestSuite
from yaml.value import YamlValue, YamlValueType
from std.collections import Dict, List


def test_null_value():
    """Test null value creation and checking."""
    var val = YamlValue()
    assert_true(val.is_null())
    assert_false(val.is_string())
    assert_false(val.is_int())


def test_string_value():
    """Test string value creation and access."""
    var val = YamlValue("hello")
    assert_true(val.is_string())
    assert_false(val.is_null())
    assert_equal(val.as_string(), "hello")


def test_int_value():
    """Test integer value creation and access."""
    var val = YamlValue(42)
    assert_true(val.is_int())
    assert_equal(val.as_int(), 42)


def test_float_value():
    """Test float value creation and access."""
    var val = YamlValue(3.14)
    assert_true(val.is_float())
    assert_equal(val.as_float(), 3.14)


def test_bool_value():
    """Test boolean value creation and access."""
    var val_true = YamlValue(True)
    var val_false = YamlValue(False)
    assert_true(val_true.is_bool())
    assert_true(val_true.as_bool())
    assert_false(val_false.as_bool())


def test_empty_sequence():
    """Test empty sequence creation."""
    var seq = List[YamlValue]()
    var val = YamlValue(seq^)
    assert_true(val.is_sequence())
    assert_false(val.is_mapping())


def test_sequence_with_values():
    """Test sequence with values."""
    var seq = List[YamlValue]()
    seq.append(YamlValue("item1"))
    seq.append(YamlValue(42))
    var val = YamlValue(seq^)

    assert_true(val.is_sequence())
    var retrieved = val.as_sequence()
    assert_equal(len(retrieved), 2)


def test_empty_mapping():
    """Test empty mapping creation."""
    var map = Dict[String, YamlValue]()
    var val = YamlValue(map^)
    assert_true(val.is_mapping())
    assert_false(val.is_sequence())


def test_mapping_with_values():
    """Test mapping with values."""
    var map = Dict[String, YamlValue]()
    map["name"] = YamlValue("test")
    map["count"] = YamlValue(10)
    var val = YamlValue(map^)

    assert_true(val.is_mapping())
    var name_val = val.get("name")
    assert_true(name_val.is_string())
    assert_equal(name_val.as_string(), "test")


def test_get_from_mapping():
    """Test get() method for mappings."""
    var map = Dict[String, YamlValue]()
    map["key1"] = YamlValue("value1")
    var val = YamlValue(map^)

    var retrieved = val.get("key1")
    assert_equal(retrieved.as_string(), "value1")


def test_get_at_from_sequence():
    """Test get_at() method for sequences."""
    var seq = List[YamlValue]()
    seq.append(YamlValue("first"))
    seq.append(YamlValue("second"))
    var val = YamlValue(seq^)

    var first = val.get_at(0)
    var second = val.get_at(1)
    assert_equal(first.as_string(), "first")
    assert_equal(second.as_string(), "second")


def test_null_copy():
    """Test copying null value."""
    var val = YamlValue()
    var copied = val.copy()
    assert_true(copied.is_null())


def test_string_copy():
    """Test copying string value."""
    var val = YamlValue("test")
    var copied = val.copy()
    assert_true(copied.is_string())
    assert_equal(copied.as_string(), "test")


def test_int_copy():
    """Test copying integer value."""
    var val = YamlValue(42)
    var copied = val.copy()
    assert_true(copied.is_int())
    assert_equal(copied.as_int(), 42)


def test_sequence_copy():
    """Test copying sequence value."""
    var seq = List[YamlValue]()
    seq.append(YamlValue("item"))
    var val = YamlValue(seq^)
    var copied = val.copy()
    assert_true(copied.is_sequence())


def test_mapping_copy():
    """Test copying mapping value."""
    var map = Dict[String, YamlValue]()
    map["key"] = YamlValue("value")
    var val = YamlValue(map^)
    var copied = val.copy()
    assert_true(copied.is_mapping())


def test_nested_structure():
    """Test nested mapping with sequence."""
    var inner_seq = List[YamlValue]()
    inner_seq.append(YamlValue(1))
    inner_seq.append(YamlValue(2))

    var outer_map = Dict[String, YamlValue]()
    outer_map["numbers"] = YamlValue(inner_seq^)
    outer_map["name"] = YamlValue("test")

    var root = YamlValue(outer_map^)
    assert_true(root.is_mapping())

    var numbers = root.get("numbers")
    assert_true(numbers.is_sequence())


def main():
    # Automatic test discovery and execution using TestSuite
    TestSuite.discover_tests[__functions_in_module()]().run()
