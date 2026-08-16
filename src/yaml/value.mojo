"""Value types for YAML.

YamlValue is a variant type that can represent any YAML value and nested
structures. Recursive sequence/mapping members are stored via boxed pointers
for Mojo 1.0 compatibility.
"""

from std.collections import Dict, List
from std.memory import alloc


struct YamlValueType:
    """Type discriminator constants for YamlValue."""
    comptime NULL: Int = 0
    comptime BOOLEAN: Int = 1
    comptime INTEGER: Int = 2
    comptime FLOAT: Int = 3
    comptime STRING: Int = 4
    comptime SEQUENCE: Int = 5
    comptime MAPPING: Int = 6


struct YamlValue(Copyable, Movable):
    """Represents any YAML value type."""

    comptime ValuePointer = Pointer[YamlValue, MutUntrackedOrigin]

    var value_type: Int
    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var sequence_value: List[Self.ValuePointer]
    var mapping_value: Dict[String, Self.ValuePointer]

    @staticmethod
    def box_value(var value: YamlValue) -> Self.ValuePointer:
        """Allocate a boxed YamlValue for recursive storage."""
        var ptr = alloc[YamlValue](1)
        ptr.unsafe_write(value^)
        return ptr

    @staticmethod
    def clone_boxed_value(value_ptr: Self.ValuePointer) -> Self.ValuePointer:
        """Deep-copy a boxed YamlValue into a new allocation."""
        var copied = value_ptr[].copy()
        return Self.box_value(copied^)

    def __init__(out self):
        """Create null value."""
        self.value_type = YamlValueType.NULL
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

    def __init__(out self, value: String):
        """Create string value."""
        self.value_type = YamlValueType.STRING
        self.string_value = value
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

    def __init__(out self, value: Int):
        """Create integer value."""
        self.value_type = YamlValueType.INTEGER
        self.string_value = ""
        self.int_value = value
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

    def __init__(out self, value: Float64):
        """Create float value."""
        self.value_type = YamlValueType.FLOAT
        self.string_value = ""
        self.int_value = 0
        self.float_value = value
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

    def __init__(out self, value: Bool):
        """Create boolean value."""
        self.value_type = YamlValueType.BOOLEAN
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = value
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

    def __init__(out self, var value: List[YamlValue]):
        """Create sequence value."""
        self.value_type = YamlValueType.SEQUENCE
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

        for i in range(len(value)):
            var element_copy = value[i].copy()
            self.sequence_value.append(Self.box_value(element_copy^))

    def __init__(out self, var value: Dict[String, YamlValue]):
        """Create mapping value."""
        self.value_type = YamlValueType.MAPPING
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

        for entry in value.items():
            var entry_copy = entry.value.copy()
            self.mapping_value[entry.key] = Self.box_value(entry_copy^)

    def __init__(out self, *, copy: Self):
        """Create a deep copy of this value."""
        self.value_type = copy.value_type
        self.string_value = copy.string_value
        self.int_value = copy.int_value
        self.float_value = copy.float_value
        self.bool_value = copy.bool_value
        self.sequence_value = List[Self.ValuePointer]()
        self.mapping_value = Dict[String, Self.ValuePointer]()

        for i in range(len(copy.sequence_value)):
            self.sequence_value.append(Self.clone_boxed_value(copy.sequence_value[i]))

        for entry in copy.mapping_value.items():
            self.mapping_value[entry.key] = Self.clone_boxed_value(entry.value)

    def __deinit__(deinit self):
        """Free boxed recursive values owned by this instance."""
        for i in range(len(self.sequence_value)):
            var ptr = self.sequence_value[i]
            ptr.unsafe_deinit_pointee()
            ptr.unsafe_free()

        for entry in self.mapping_value.items():
            var ptr = entry.value
            ptr.unsafe_deinit_pointee()
            ptr.unsafe_free()

    @staticmethod
    def null() -> YamlValue:
        """Create a null value."""
        return YamlValue()

    @staticmethod
    def bool(value: Bool) -> YamlValue:
        """Create a boolean value."""
        return YamlValue(value)

    @staticmethod
    def integer(value: Int) -> YamlValue:
        """Create an integer value."""
        return YamlValue(value)

    @staticmethod
    def float(value: Float64) -> YamlValue:
        """Create a float value."""
        return YamlValue(value)

    @staticmethod
    def string(value: String) -> YamlValue:
        """Create a string value."""
        return YamlValue(value)

    @staticmethod
    def sequence(var value: List[YamlValue]) -> YamlValue:
        """Create a sequence value."""
        return YamlValue(value^)

    @staticmethod
    def mapping(var value: Dict[String, YamlValue]) -> YamlValue:
        """Create a mapping value."""
        return YamlValue(value^)

    def is_null(self) -> Bool:
        return self.value_type == YamlValueType.NULL

    def is_bool(self) -> Bool:
        return self.value_type == YamlValueType.BOOLEAN

    def is_int(self) -> Bool:
        return self.value_type == YamlValueType.INTEGER

    def is_float(self) -> Bool:
        return self.value_type == YamlValueType.FLOAT

    def is_string(self) -> Bool:
        return self.value_type == YamlValueType.STRING

    def is_sequence(self) -> Bool:
        return self.value_type == YamlValueType.SEQUENCE

    def is_mapping(self) -> Bool:
        return self.value_type == YamlValueType.MAPPING

    def as_string(self) raises -> String:
        if not self.is_string():
            raise Error("Value is not a string")
        return self.string_value

    def as_int(self) raises -> Int:
        if not self.is_int():
            raise Error("Value is not an integer")
        return self.int_value

    def as_float(self) raises -> Float64:
        if not self.is_float():
            raise Error("Value is not a float")
        return self.float_value

    def as_bool(self) raises -> Bool:
        if not self.is_bool():
            raise Error("Value is not a boolean")
        return self.bool_value

    def as_sequence(self) raises -> List[YamlValue]:
        if not self.is_sequence():
            raise Error("Value is not a sequence")
        var seq_copy = List[YamlValue]()
        for i in range(len(self.sequence_value)):
            seq_copy.append(self.sequence_value[i][].copy())
        return seq_copy^

    def as_mapping(self) raises -> Dict[String, YamlValue]:
        if not self.is_mapping():
            raise Error("Value is not a mapping")
        var map_copy = Dict[String, YamlValue]()
        for entry in self.mapping_value.items():
            map_copy[entry.key] = entry.value[].copy()
        return map_copy^

    def get(self, key: String) raises -> YamlValue:
        if not self.is_mapping():
            raise Error("Value is not a mapping")
        if key not in self.mapping_value:
            raise Error("Key not found: " + key)
        return self.mapping_value[key][].copy()

    def get_at(self, index: Int) raises -> YamlValue:
        if not self.is_sequence():
            raise Error("Value is not a sequence")
        if index < 0 or index >= len(self.sequence_value):
            raise Error("Index out of bounds")
        return self.sequence_value[index][].copy()

    def copy(self) -> Self:
        return Self(copy=self)
