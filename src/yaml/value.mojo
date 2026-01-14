"""Value types for YAML.

# Why: Purpose of YamlValue
YamlValue is a variant type that can represent any YAML value. YAML has fewer
types than TOML but needs to handle nested structures (mappings and sequences).

# What: Responsibilities
- Represent all YAML scalar types (string, int, float, bool, null)
- Support nested structures (sequences/lists and mappings/dicts)
- Provide type checking and safe accessor methods
- Enable recursive data structures for nested YAML

# How: Design
Uses a discriminated union pattern:
- Store all possible value types in fields
- Use value_type int to track which field is active
- Provide type-safe accessors that raise on wrong type access
"""

from collections import Dict, List


# Type constants for YamlValue discrimination
struct YamlValueType:
    """Type discriminator constants for YamlValue."""
    comptime NULL: Int = 0
    comptime BOOLEAN: Int = 1
    comptime INTEGER: Int = 2
    comptime FLOAT: Int = 3
    comptime STRING: Int = 4
    comptime SEQUENCE: Int = 5  # YAML lists
    comptime MAPPING: Int = 6   # YAML dicts


struct YamlValue(Copyable, Movable):
    """Represents any YAML value type.

    YAML supports: null, booleans, integers, floats, strings,
    sequences (lists), and mappings (nested dicts).
    
    Usage:
        var str_val = YamlValue("hello")
        var int_val = YamlValue(42)
        var list_val = YamlValue(List[YamlValue]())
        var dict_val = YamlValue(Dict[String, YamlValue]())
    """

    var value_type: Int
    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var sequence_value: List[YamlValue]
    var mapping_value: Dict[String, YamlValue]

    fn __init__(out self):
        """Create null value."""
        self.value_type = YamlValueType.NULL
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[YamlValue]()
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, value: String):
        """Create string value."""
        self.value_type = YamlValueType.STRING
        self.string_value = value
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[YamlValue]()
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, value: Int):
        """Create integer value."""
        self.value_type = YamlValueType.INTEGER
        self.string_value = ""
        self.int_value = value
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[YamlValue]()
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, value: Float64):
        """Create float value."""
        self.value_type = YamlValueType.FLOAT
        self.string_value = ""
        self.int_value = 0
        self.float_value = value
        self.bool_value = False
        self.sequence_value = List[YamlValue]()
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, value: Bool):
        """Create boolean value."""
        self.value_type = YamlValueType.BOOLEAN
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = value
        self.sequence_value = List[YamlValue]()
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, var value: List[YamlValue]):
        """Create sequence (list) value."""
        self.value_type = YamlValueType.SEQUENCE
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = value^
        self.mapping_value = Dict[String, YamlValue]()

    fn __init__(out self, var value: Dict[String, YamlValue]):
        """Create mapping (dict) value."""
        self.value_type = YamlValueType.MAPPING
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[YamlValue]()
        self.mapping_value = value^

    # Type checking methods
    fn is_null(self) -> Bool:
        """Check if value is null."""
        return self.value_type == YamlValueType.NULL

    fn is_bool(self) -> Bool:
        """Check if value is boolean."""
        return self.value_type == YamlValueType.BOOLEAN

    fn is_int(self) -> Bool:
        """Check if value is integer."""
        return self.value_type == YamlValueType.INTEGER

    fn is_float(self) -> Bool:
        """Check if value is float."""
        return self.value_type == YamlValueType.FLOAT

    fn is_string(self) -> Bool:
        """Check if value is string."""
        return self.value_type == YamlValueType.STRING

    fn is_sequence(self) -> Bool:
        """Check if value is sequence (list)."""
        return self.value_type == YamlValueType.SEQUENCE

    fn is_mapping(self) -> Bool:
        """Check if value is mapping (dict)."""
        return self.value_type == YamlValueType.MAPPING

    # Accessor methods with type checking
    fn as_string(self) raises -> String:
        """Get string value.
        
        Raises:
            Error: If value is not a string.
        """
        if not self.is_string():
            raise Error("Value is not a string")
        return self.string_value

    fn as_int(self) raises -> Int:
        """Get integer value.
        
        Raises:
            Error: If value is not an integer.
        """
        if not self.is_int():
            raise Error("Value is not an integer")
        return self.int_value

    fn as_float(self) raises -> Float64:
        """Get float value.
        
        Raises:
            Error: If value is not a float.
        """
        if not self.is_float():
            raise Error("Value is not a float")
        return self.float_value

    fn as_bool(self) raises -> Bool:
        """Get boolean value.
        
        Raises:
            Error: If value is not a boolean.
        """
        if not self.is_bool():
            raise Error("Value is not a boolean")
        return self.bool_value

    fn as_sequence(self) raises -> List[YamlValue]:
        """Get sequence (list) value (returns a copy).
        
        Raises:
            Error: If value is not a sequence.
        """
        if not self.is_sequence():
            raise Error("Value is not a sequence")
        # Return a copy to avoid ownership issues
        var seq_copy = List[YamlValue]()
        for i in range(len(self.sequence_value)):
            seq_copy.append(self.sequence_value[i].copy())
        return seq_copy^

    fn as_mapping(self) raises -> Dict[String, YamlValue]:
        """Get mapping (dict) value.
        
        Raises:
            Error: If value is not a mapping.
        """
        if not self.is_mapping():
            raise Error("Value is not a mapping")
        return self.mapping_value

    fn get(self, key: String) raises -> YamlValue:
        """Get value by key from mapping (returns a copy).
        
        Args:
            key: The key to look up.
            
        Returns:
            The value associated with the key.
            
        Raises:
            Error: If value is not a mapping or key doesn't exist.
        """
        if not self.is_mapping():
            raise Error("Value is not a mapping")
        return self.mapping_value[key].copy()

    fn get_at(self, index: Int) raises -> YamlValue:
        """Get value by index from sequence (returns a copy).
        
        Args:
            index: The index to look up.
            
        Returns:
            The value at the index.
            
        Raises:
            Error: If value is not a sequence or index out of bounds.
        """
        if not self.is_sequence():
            raise Error("Value is not a sequence")
        if index < 0 or index >= len(self.sequence_value):
            raise Error("Index out of bounds")
        return self.sequence_value[index].copy()

    fn copy(self) -> Self:
        """Create a deep copy of this value."""
        if self.value_type == YamlValueType.NULL:
            return YamlValue()
        elif self.value_type == YamlValueType.BOOLEAN:
            return YamlValue(self.bool_value)
        elif self.value_type == YamlValueType.INTEGER:
            return YamlValue(self.int_value)
        elif self.value_type == YamlValueType.FLOAT:
            return YamlValue(self.float_value)
        elif self.value_type == YamlValueType.STRING:
            return YamlValue(self.string_value)
        elif self.value_type == YamlValueType.SEQUENCE:
            var seq_copy = List[YamlValue]()
            for i in range(len(self.sequence_value)):
                seq_copy.append(self.sequence_value[i].copy())
            return YamlValue(seq_copy^)
        elif self.value_type == YamlValueType.MAPPING:
            var map_copy = Dict[String, YamlValue]()
            for entry in self.mapping_value.items():
                map_copy[entry.key] = entry.value.copy()
            return YamlValue(map_copy^)
        else:
            # Should not reach here
            return YamlValue()
