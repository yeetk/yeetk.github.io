# FFI Semantics

This page describes the detailed semantics underlying the FFI library and its interaction with both Lua and C code.
这个页面描述了FFI库底层的详细语义，以及它与Lua和C代码的交互。

Given that the FFI library is designed to interface with C code and that declarations can be written in plain C syntax, **it closely follows the C language semantics**, wherever possible. Some minor concessions are needed for smoother interoperation with Lua language semantics.

考虑到FFI库被设计成与C代码交互，并且声明可以用普通的C语法编写，**它尽可能地紧跟C语言语义**。为了更顺畅地与Lua语言语义进行互操作，需要做一些小小的让步。这个页面描述了FFI库底层的详细语义，以及它与Lua和C代码的交互。

Please don't be overwhelmed by the contents of this page — this is a reference and you may need to consult it, if in doubt. It doesn't hurt to skim this page, but most of the semantics "just work" as you'd expect them to work. It should be straightforward to write applications using the LuaJIT FFI for developers with a C or C++ background.

请不要被这页的内容压倒-这是一个参考，你可能需要查阅它，如果有疑问。浏览这个页面没有什么坏处，但是大多数语义“只是工作”，正如你所期望的那样。使用LuaJIT FFI为具有C或c++背景的开发人员编写应用程序应该很简单。

## C Language Support

The FFI library has a built-in C parser with a minimal memory footprint. It's used by the [ffi.* library functions](http://luajit.org/ext_ffi_api.html) to declare C types or external symbols.

FFI库有一个内置的C解析器，占用的内存最少。它被[ffi.*库函数](http://luajit.org/ext_ffi_api.html)用来声明C类型或外部符号。

It's only purpose is to parse C declarations, as found e.g. in C header files. Although it does evaluate constant expressions, it's *not* a C compiler. The body of inline C function definitions is simply ignored.

它的唯一目的是解析C声明，如在C头文件中发现的。虽然它计算常量表达式，但它不是C编译器。内联C函数定义的主体被简单地忽略。

Also, this is *not* a validating C parser. It expects and accepts correctly formed C declarations, but it may choose to ignore bad declarations or show rather generic error messages. If in doubt, please check the input against your favorite C compiler.

另外，这不是一个验证的C解析器。它期望并接受正确格式的C声明，但是它可以选择忽略错误的声明，或者显示通用的错误消息。如果有疑问，请根据您喜欢的C编译器检查输入。

The C parser complies to the **C99 language standard** plus the following extensions:

C解析器符合**C99语言标准**加上以下扩展:

- The `'\e'` escape in character and string literals. 

  '\e'在字符和字符串文本中转义。

- The C99/C++ boolean type, declared with the keywords `bool` or `_Bool`. 

  C99/ C++布尔类型，用关键字`bool`或`_Bool`声明。

- Complex numbers, declared with the keywords `complex` or `_Complex`. 

  复数，用关键字`complex`或`_Complex`声明。

- Two complex number types: `complex` (aka `complex double`) and `complex float`. 

  有两种复数类型: `complex`(又名`complex double`)和`complex float`。

- Vector types, declared with the GCC `mode` or `vector_size` attribute. 

  向量类型，用GCC `mode`或`vector_size `属性声明。

- Unnamed ('transparent') `struct`/`union` fields inside a `struct`/`union`. 

  不愿透露姓名的(透明的)`struct ` / ` union `中的`struct ` /` union `字段。

- Incomplete `enum` declarations, handled like incomplete `struct` declarations. 

  不完整的` enum `声明，处理方式类似于不完整的` struct `声明。

- Unnamed `enum` fields inside a `struct`/`union`. This is similar to a scoped C++ `enum`, except that declared constants are visible in the global namespace, too. 

  ` struct ` /` union `中的未命名` enum `字段。这类似于限定了作用域的C++ `enum`，只是声明的常量在全局命名空间中也是可见的。

- Scoped `static const` declarations inside a `struct`/`union` (from C++). 

  在`struct ` / `union `(来自C++)中定义了`static const`声明的作用域。

- Zero-length arrays (`[0]`), empty `struct`/`union`, variable-length arrays (VLA, `[?]`) and variable-length structs (VLS, with a trailing VLA). 

  零长度数组(`[0]`)，空`struct `/ `union`，可变长度数组(VLA，`[?]`)和可变长度结构体(VLS，末尾有VLA)。

- C++ reference types (`int &x`). 

  C++引用类型(`int &x`)。

- Alternate GCC keywords with '`__`', e.g. `__const__`. 

  用 '`__`'替换GCC关键字，例如: `__const__`。

- GCC `__attribute__` with the following attributes: `aligned`, `packed`, `mode`, `vector_size`, `cdecl`, `fastcall`, `stdcall`, `thiscall`. 

  带有以下属性的GCC ` __attribute__`: `aligned`、`packed`、`mode`、`vector_size`、`cdecl`、`fastcall`、`stdcall`、`thiscall`。

- The GCC `__extension__` keyword and the GCC `__alignof__` operator. --GCC `__extension__`关键字和GCC `__alignof__`操作符。

- GCC `__asm__("symname")` symbol name redirection for function declarations. --GCC `__asm__("symname")`函数声明的符号名称重定向。

- MSVC keywords for fixed-length types: `__int8`, `__int16`, `__int32` and `__int64`. --固定长度类型的MSVC关键字:“_int8”、“_int16”、“_int32”和“_int64”。

- MSVC `__cdecl`, `__fastcall`, `__stdcall`, `__thiscall`, `__ptr32`, `__ptr64`, `__declspec(align(n))` and `#pragma pack`. --MSVC‘__cdecl’,‘__fastcall’,‘__stdcall’,‘__thiscall’,‘__ptr32’,‘__ptr64’,“使用__declspec(对齐(n))”和“# pragma包”。

- All other GCC/MSVC-specific attributes are ignored. --所有其他GCC/ msvc特定的属性都会被忽略。

The following C types are pre-defined by the C parser (like a `typedef`, except re-declarations will be ignored):

以下C类型是由C解析器预先定义的(类似于‘typedef’，除非重新声明，否则会被忽略):

- Vararg handling: `va_list`, `__builtin_va_list`, `__gnuc_va_list`. --Vararg处理
- From ``: `ptrdiff_t`, `size_t`, `wchar_t`.
- From ``: `int8_t`, `int16_t`, `int32_t`, `int64_t`, `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t`, `intptr_t`, `uintptr_t`.

You're encouraged to use these types in preference to compiler-specific extensions or target-dependent standard types. E.g. `char` differs in signedness and `long` differs in size, depending on the target architecture and platform ABI.

建议您优先使用这些类型，而不是特定于编译器的扩展或依赖于目标的标准类型。如。“char”在符号上不同，“long”在大小上不同，这取决于目标架构和平台ABI。

The following C features are **not** supported:

下列C功能**不**支持:

- A declaration must always have a type specifier; it doesn't default to an `int` type. --声明必须始终有类型说明符;它不默认为' int '类型。
- Old-style empty function declarations (K&R) are not allowed. All C functions must have a proper prototype declaration. A function declared without parameters (`int foo();`) is treated as a function taking zero arguments, like in C++. --不允许使用老式的空函数声明(K&R)。所有C函数必须有一个适当的原型声明。没有参数声明的函数(' int foo(); ')被视为接受零参数的函数，就像在c++中一样。
- The `long double` C type is parsed correctly, but there's no support for the related conversions, accesses or arithmetic operations. --“long double”C类型被正确解析，但是不支持相关的转换、访问或算术操作。
- Wide character strings and character literals are not supported. --不支持宽字符串和字符文字。
- [See below](http://luajit.org/ext_ffi_semantics.html#status) for features that are currently not implemented. --[参见下面](http://luajit.org/ext_ffi_semantics.html#status)查看当前未实现的功能。

## C Type Conversion Rules --C类型转换规则

### Conversions from C types to Lua objects

从C类型到Lua对象的转换

These conversion rules apply for *read accesses* to C types: indexing pointers, arrays or `struct`/`union` types; reading external variables or constant values; retrieving return values from C calls:

这些转换规则适用于*读访问*到C类型:索引指针，数组或' struct ' / ' union '类型;读取外部变量或常量值;从C调用中检索返回值:

| Input                 | Conversion                     | Output           |
| --------------------- | ------------------------------ | ---------------- |
| `int8_t`, `int16_t`   | →sign-ext `int32_t` → `double` | number           |
| `uint8_t`, `uint16_t` | →zero-ext `int32_t` → `double` | number           |
| `int32_t`, `uint32_t` | → `double`                     | number           |
| `int64_t`, `uint64_t` | boxed value                    | 64 bit int cdata |
| `double`, `float`     | → `double`                     | number           |
| `bool`                | 0 → `false`, otherwise `true`  | boolean          |
| `enum`                | boxed value                    | enum cdata       |
| Complex number        | boxed value                    | complex cdata    |
| Vector                | boxed value                    | vector cdata     |
| Pointer               | boxed value                    | pointer cdata    |
| Array                 | boxed reference                | reference cdata  |
| `struct`/`union`      | boxed reference                | reference cdata  |

Bitfields are treated like their underlying type.

位字段被视为它们的基础类型。

Reference types are dereferenced *before* a conversion can take place — the conversion is applied to the C type pointed to by the reference.

引用类型在转换发生之前被取消引用引用-转换被应用到引用指向的C类型。

### Conversions from Lua objects to C types

从Lua对象到C类型的转换

These conversion rules apply for *write accesses* to C types: indexing pointers, arrays or `struct`/`union` types; initializing cdata objects; casts to C types; writing to external variables; passing arguments to C calls:

这些转换规则适用于*写访问*到C类型:索引指针，数组或' struct ' / ' union '类型;初始化cdata对象;强制转换为C类型;写入外部变量;传递参数给C调用:

| Input         | Conversion                                                   | Output                  |
| ------------- | ------------------------------------------------------------ | ----------------------- |
| number        | →                                                            | `double`                |
| boolean       | `false` → 0, `true` → 1                                      | `bool`                  |
| nil           | `NULL` →                                                     | `(void *)`              |
| lightuserdata | lightuserdata address →                                      | `(void *)`              |
| userdata      | userdata payload →                                           | `(void *)`              |
| io.* file     | get FILE * handle →                                          | `(void *)`              |
| string        | match against `enum` constant                                | `enum`                  |
| string        | copy string data + zero-byte                                 | `int8_t[]`, `uint8_t[]` |
| string        | string data →                                                | `const char[]`          |
| function      | [create callback](http://luajit.org/ext_ffi_semantics.html#callback) → | C function type         |
| table         | [table initializer](http://luajit.org/ext_ffi_semantics.html#init_table) | Array                   |
| table         | [table initializer](http://luajit.org/ext_ffi_semantics.html#init_table) | `struct`/`union`        |
| cdata         | cdata payload →                                              | C type                  |

If the result type of this conversion doesn't match the C type of the destination, the [conversion rules between C types](http://luajit.org/ext_ffi_semantics.html#convert_between) are applied.

如果转换的结果类型与目标的C类型不匹配，则应用[C类型之间的转换规则](http://luajit.org/ext_ffi_semantics.html#convert_between)。

Reference types are immutable after initialization ("no re-seating of references"). For initialization purposes or when passing values to reference parameters, they are treated like pointers. Note that unlike in C++, there's no way to implement automatic reference generation of variables under the Lua language semantics. If you want to call a function with a reference parameter, you need to explicitly pass a one-element array.

引用类型在初始化之后是不可变的(“不重新放置引用”)。出于初始化目的，或者在将值传递给引用参数时，它们被视为指针。注意，与c++中不同的是，在Lua语言语义下无法实现变量的自动引用生成。如果希望调用带有引用参数的函数，则需要显式传递一个单元素数组。

### Conversions between C types

C类型之间的转换

These conversion rules are more or less the same as the standard C conversion rules. Some rules only apply to casts, or require pointer or type compatibility:

这些转换规则或多或少与标准的C转换规则相同。有些规则只适用于强制类型转换，或者需要指针或类型兼容性:

| Input             | Conversion                     | Output                     |
| ----------------- | ------------------------------ | -------------------------- |
| Signed integer    | →narrow or sign-extend         | Integer                    |
| Unsigned integer  | →narrow or zero-extend         | Integer                    |
| Integer           | →round                         | `double`, `float`          |
| `double`, `float` | →trunc `int32_t` →narrow       | `(u)int8_t`, `(u)int16_t`  |
| `double`, `float` | →trunc                         | `(u)int32_t`, `(u)int64_t` |
| `double`, `float` | →round                         | `float`, `double`          |
| Number            | n == 0 → 0, otherwise 1        | `bool`                     |
| `bool`            | `false` → 0, `true` → 1        | Number                     |
| Complex number    | convert real part              | Number                     |
| Number            | convert real part, imag = 0    | Complex number             |
| Complex number    | convert real and imag part     | Complex number             |
| Number            | convert scalar and replicate   | Vector                     |
| Vector            | copy (same size)               | Vector                     |
| `struct`/`union`  | take base address (compat)     | Pointer                    |
| Array             | take base address (compat)     | Pointer                    |
| Function          | take function address          | Function pointer           |
| Number            | convert via `uintptr_t` (cast) | Pointer                    |
| Pointer           | convert address (compat/cast)  | Pointer                    |
| Pointer           | convert address (cast)         | Integer                    |
| Array             | convert base address (cast)    | Integer                    |
| Array             | copy (compat)                  | Array                      |
| `struct`/`union`  | copy (identical type)          | `struct`/`union`           |

Bitfields or `enum` types are treated like their underlying type.

位字段或‘enum’类型被视为它们的基础类型。

Conversions not listed above will raise an error. E.g. it's not possible to convert a pointer to a complex number or vice versa.

未在上面列出的转换将引发错误。例如，不可能将指针转换成复数，反之亦然。

### Conversions for vararg C function arguments

vararg C函数参数的转换

The following default conversion rules apply when passing Lua objects to the variable argument part of vararg C functions:

当将Lua对象传递给vararg C函数的变量参数部分时，应用以下默认转换规则:

| Input                  | Conversion              | Output                   |
| ---------------------- | ----------------------- | ------------------------ |
| number                 | →                       | `double`                 |
| boolean                | `false` → 0, `true` → 1 | `bool`                   |
| nil                    | `NULL` →                | `(void *)`               |
| userdata               | userdata payload →      | `(void *)`               |
| lightuserdata          | lightuserdata address → | `(void *)`               |
| string                 | string data →           | `const char *`           |
| `float` cdata          | →                       | `double`                 |
| Array cdata            | take base address       | Element pointer          |
| `struct`/`union` cdata | take base address       | `struct`/`union` pointer |
| Function cdata         | take function address   | Function pointer         |
| Any other cdata        | no conversion           | C type                   |

To pass a Lua object, other than a cdata object, as a specific type, you need to override the conversion rules: create a temporary cdata object with a constructor or a cast and initialize it with the value to pass:

要传递一个Lua对象，而不是cdata对象，作为一个特定的类型，您需要重写转换规则:创建一个临时的cdata对象，使用构造函数或强制类型转换，并使用要传递的值初始化它:

Assuming `x` is a Lua number, here's how to pass it as an integer to a vararg function:

假设“x”是一个Lua数字，下面是如何把它作为一个整数传递给一个vararg函数:

```
ffi.cdef[[
int printf(const char *fmt, ...);
]]
ffi.C.printf("integer value: %d\n", ffi.new("int", x))
```

If you don't do this, the default Lua number → `double` conversion rule applies. A vararg C function expecting an integer will see a garbled or uninitialized value.

如果不这样做，则应用默认的Lua数字→' double '转换规则。期望整数的vararg C函数将看到一个混乱的或未初始化的值。

## Initializers

初始化器

Creating a cdata object with [`ffi.new()`](http://luajit.org/ext_ffi_api.html#ffi_new) or the equivalent constructor syntax always initializes its contents, too. Different rules apply, depending on the number of optional initializers and the C types involved:

使用[' ffi.new() '](http://luajit.org/ext_ffi_api.html#ffi_new)或等效的构造函数语法创建一个cdata对象，也总是初始化它的内容。根据可选初始化器的数量和涉及的C类型，适用不同的规则:

- If no initializers are given, the object is filled with zero bytes. --如果没有提供初始化器，则对象将被零字节填充。
- Scalar types (numbers and pointers) accept a single initializer. The Lua object is [converted to the scalar C type](http://luajit.org/ext_ffi_semantics.html#convert_fromlua). --标量类型(数字和指针)接受单个初始化器。Lua对象[转换为标量C类型](http://luajit.org/ext_ffi_semantics.html#convert_fromlua)。
- Valarrays (complex numbers and vectors) are treated like scalars when a single initializer is given. Otherwise they are treated like regular arrays. --当给定一个初始值设定项时，阀值(复数和向量)被视为标量。否则，它们将被视为常规数组。
- Aggregate types (arrays and structs) accept either a single cdata initializer of the same type (copy constructor), a single [table initializer](http://luajit.org/ext_ffi_semantics.html#init_table), or a flat list of initializers. --聚合类型(数组和结构体)可以接受同一类型的单个cdata初始化器(复制构造函数)、单个[表初始化器](http://luajit.org/ext_ffi_semantics.html#init_table)，也可以接受初始化器的平面列表。
- The elements of an array are initialized, starting at index zero. If a single initializer is given for an array, it's repeated for all remaining elements. This doesn't happen if two or more initializers are given: all remaining uninitialized elements are filled with zero bytes. --数组的元素被初始化，从索引0开始。如果为一个数组提供了一个初始化器，则对所有其余元素重复该初始化器。如果给定两个或多个初始化器，则不会发生这种情况:所有剩余的未初始化元素都用零字节填充。
- Byte arrays may also be initialized with a Lua string. This copies the whole string plus a terminating zero-byte. The copy stops early only if the array has a known, fixed size. --字节数组也可以用Lua字符串初始化。这将复制整个字符串加上一个终止的零字节。只有当数组具有已知的固定大小时，复制才会提前停止。
- The fields of a `struct` are initialized in the order of their declaration. Uninitialized fields are filled with zero bytes. --“结构体”的字段按其声明的顺序初始化。未初始化的字段用零字节填充。
- Only the first field of a `union` can be initialized with a flat initializer. --只有“union”的第一个字段可以用平面初始化器进行初始化。
- Elements or fields which are aggregates themselves are initialized with a *single* initializer, but this may be a table initializer or a compatible aggregate. --本身是聚合的元素或字段使用*single* initializer进行初始化，但这可能是表初始化器或兼容的聚合。
- Excess initializers cause an error. --过量的初始化器会导致错误。

## Table Initializers

表初始化

The following rules apply if a Lua table is used to initialize an Array or a `struct`/`union`:

如果使用Lua表初始化数组或' struct ' / ' union '，则适用以下规则:

- If the table index `[0]` is non-`nil`, then the table is assumed to be zero-based. Otherwise it's assumed to be one-based. --如果表索引'[0]'是非' nil '，则假定该表是从零开始的。否则就假定它是基于一的。
- Array elements, starting at index zero, are initialized one-by-one with the consecutive table elements, starting at either index `[0]` or `[1]`. This process stops at the first `nil` table element. --数组元素从索引0开始，由连续的表元素逐个初始化，从索引'[0]'或'[1]'开始。这个过程在第一个“nil”表元素处停止。
- If exactly one array element was initialized, it's repeated for all the remaining elements. Otherwise all remaining uninitialized elements are filled with zero bytes. --如果只初始化了一个数组元素，则对其余所有元素重复该数组元素。否则，所有剩余的未初始化元素都用零字节填充。
- The above logic only applies to arrays with a known fixed size. A VLA is only initialized with the element(s) given in the table. Depending on the use case, you may need to explicitly add a `NULL` or `0` terminator to a VLA. --上述逻辑仅适用于已知固定大小的数组。VLA仅使用表中给出的元素进行初始化。根据用例的不同，您可能需要显式地向VLA添加“NULL”或“0”终止符。
- A `struct`/`union` can be initialized in the order of the declaration of its fields. Each field is initialized with consecutive table elements, starting at either index `[0]` or `[1]`. This process stops at the first `nil` table element. --可以按字段声明的顺序初始化' struct ' / ' union '。每个字段由连续的表元素初始化，从索引'[0]'或'[1]'开始。这个过程在第一个“nil”表元素处停止。
- Otherwise, if neither index `[0]` nor `[1]` is present, a `struct`/`union` is initialized by looking up each field name (as a string key) in the table. Each non-`nil` value is used to initialize the corresponding field. --否则，如果索引'[0]'和'[1]'都不存在，则通过查找表中的每个字段名(作为字符串键)来初始化' struct ' / ' union '。每个非' nil '值用于初始化相应的字段。
- Uninitialized fields of a `struct` are filled with zero bytes, except for the trailing VLA of a VLS. --“struct”的未初始化字段除VLS的末尾VLA外，其余都用零字节填充。
- Initialization of a `union` stops after one field has been initialized. If no field has been initialized, the `union` is filled with zero bytes. --' union '的初始化在一个字段初始化后停止。如果没有初始化字段，则“union”用零字节填充。
- Elements or fields which are aggregates themselves are initialized with a *single* initializer, but this may be a nested table initializer (or a compatible aggregate). --本身是聚合的元素或字段使用*single* initializer进行初始化，但这可能是嵌套的表初始化器(或兼容的聚合)。
- Excess initializers for an array cause an error. Excess initializers for a `struct`/`union` are ignored. Unrelated table entries are ignored, too. --数组中过多的初始化器会导致错误。“struct”/“union”的多余初始化器将被忽略。不相关的表项也会被忽略。

Example:

```
local ffi = require("ffi")

ffi.cdef[[
struct foo { int a, b; };
union bar { int i; double d; };
struct nested { int x; struct foo y; };
]]

ffi.new("int[3]", {})            --> 0, 0, 0
ffi.new("int[3]", {1})           --> 1, 1, 1
ffi.new("int[3]", {1,2})         --> 1, 2, 0
ffi.new("int[3]", {1,2,3})       --> 1, 2, 3
ffi.new("int[3]", {[0]=1})       --> 1, 1, 1
ffi.new("int[3]", {[0]=1,2})     --> 1, 2, 0
ffi.new("int[3]", {[0]=1,2,3})   --> 1, 2, 3
ffi.new("int[3]", {[0]=1,2,3,4}) --> error: too many initializers

ffi.new("struct foo", {})            --> a = 0, b = 0
ffi.new("struct foo", {1})           --> a = 1, b = 0
ffi.new("struct foo", {1,2})         --> a = 1, b = 2
ffi.new("struct foo", {[0]=1,2})     --> a = 1, b = 2
ffi.new("struct foo", {b=2})         --> a = 0, b = 2
ffi.new("struct foo", {a=1,b=2,c=3}) --> a = 1, b = 2  'c' is ignored

ffi.new("union bar", {})        --> i = 0, d = 0.0
ffi.new("union bar", {1})       --> i = 1, d = ?
ffi.new("union bar", {[0]=1,2}) --> i = 1, d = ?    '2' is ignored
ffi.new("union bar", {d=2})     --> i = ?, d = 2.0

ffi.new("struct nested", {1,{2,3}})     --> x = 1, y.a = 2, y.b = 3
ffi.new("struct nested", {x=1,y={2,3}}) --> x = 1, y.a = 2, y.b = 3
```

## Operations on cdata Objects

对cdata对象的操作

All of the standard Lua operators can be applied to cdata objects or a mix of a cdata object and another Lua object. The following list shows the pre-defined operations.

所有标准的Lua操作符都可以应用于cdata对象或cdata对象和另一个Lua对象的组合。下面的列表显示了预定义的操作。

Reference types are dereferenced *before* performing each of the operations below — the operation is applied to the C type pointed to by the reference.

引用类型在*执行下面的每个操作之前被取消引用引用-操作被应用到引用指向的C类型。

The pre-defined operations are always tried first before deferring to a metamethod or index table (if any) for the corresponding ctype (except for `__new`). An error is raised if the metamethod lookup or index table lookup fails.

在向对应的ctype的元方法或索引表(如果有的话)提交之前，总是先尝试预定义的操作(除了' new ')。如果元方法查找或索引表查找失败，将引发错误。

### Indexing a cdata object

索引cdata对象

- **Indexing a pointer/array**: a cdata pointer/array can be indexed by a cdata number or a Lua number. The element address is computed as the base address plus the number value multiplied by the element size in bytes. A read access loads the element value and [converts it to a Lua object](http://luajit.org/ext_ffi_semantics.html#convert_tolua). A write access [converts a Lua object to the element type](http://luajit.org/ext_ffi_semantics.html#convert_fromlua) and stores the converted value to the element. An error is raised if the element size is undefined or a write access to a constant element is attempted.
- **索引指针/数组**:cdata指针/数组可以通过cdata编号或Lua编号索引。元素地址计算为基本地址加上用字节表示的元素大小乘以的数值。读取访问加载元素值并[将其转换为Lua对象](http://luajit.org/ext_ffi_semantics.html#convert_tolua)。写访问[将Lua对象转换为元素类型](http://luajit.org/ext_ffi_semantics.html#convert_fromlua)并将转换后的值存储到元素中。如果元素大小未定义或试图对常量元素进行写访问，则会引发错误。
- **Dereferencing a `struct`/`union` field**: a cdata `struct`/`union` or a pointer to a `struct`/`union` can be dereferenced by a string key, giving the field name. The field address is computed as the base address plus the relative offset of the field. A read access loads the field value and [converts it to a Lua object](http://luajit.org/ext_ffi_semantics.html#convert_tolua). A write access [converts a Lua object to the field type](http://luajit.org/ext_ffi_semantics.html#convert_fromlua) and stores the converted value to the field. An error is raised if a write access to a constant `struct`/`union` or a constant field is attempted. Scoped enum constants or static constants are treated like a constant field.
- **取消对' struct ' / ' union '字段的引用**:cdata ' struct ' / ' union '或指向' struct ' / ' union '的指针可以通过字符串键取消引用，给出字段名。字段地址计算为基本地址加上字段的相对偏移量。读取访问加载字段值并[将其转换为Lua对象](http://luajit.org/ext_ffi_semantics.html#convert_tolua)。写访问[将Lua对象转换为字段类型](http://luajit.org/ext_ffi_semantics.html#convert_fromlua)并将转换后的值存储到字段中。如果试图对常量' struct ' / ' union '或常量字段进行写访问，则会引发错误。作用域enum常量或静态常量被视为常量字段。
- **Indexing a complex number**: a complex number can be indexed either by a cdata number or a Lua number with the values 0 or 1, or by the strings `"re"` or `"im"`. A read access loads the real part (`[0]`, `.re`) or the imaginary part (`[1]`, `.im`) part of a complex number and [converts it to a Lua number](http://luajit.org/ext_ffi_semantics.html#convert_tolua). The sub-parts of a complex number are immutable — assigning to an index of a complex number raises an error. Accessing out-of-bound indexes returns unspecified results, but is guaranteed not to trigger memory access violations.
- **索引一个复数**:一个复数可以由一个cdata编号或一个Lua编号(值为0或1)来索引，也可以由字符串“re”或“im”来索引。读取访问加载复数的实部(' [0]'，' .re ')或虚部(' [1]'，' .im ')并[将其转换为Lua数字](http://luajit.org/ext_ffi_semantics.html#convert_tolua)。复数的子部分是不可变的——给一个复数的索引赋值会引起错误。访问未绑定的索引将返回未指定的结果，但保证不会触发内存访问违规。
- **Indexing a vector**: a vector is treated like an array for indexing purposes, except the vector elements are immutable — assigning to an index of a vector raises an error.
- **索引一个向量**:一个向量被当作一个数组进行索引，除了向量元素是不可变的——赋值给一个向量的索引会引起一个错误。

A ctype object can be indexed with a string key, too. The only pre-defined operation is reading scoped constants of `struct`/`union` types. All other accesses defer to the corresponding metamethods or index tables (if any).

ctype对象也可以用字符串键建立索引。唯一预先定义的操作是读取“struct”/“union”类型的作用域常量。所有其他访问都遵从相应的元方法或索引表(如果有的话)。

Note: since there's (deliberately) no address-of operator, a cdata object holding a value type is effectively immutable after initialization. The JIT compiler benefits from this fact when applying certain optimizations.

注意:由于(故意)没有address-of操作符，所以持有值类型的cdata对象在初始化之后实际上是不可变的。JIT编译器在应用某些优化时可以从这个事实中获益。

As a consequence, the *elements* of complex numbers and vectors are immutable. But the elements of an aggregate holding these types *may* be modified of course. I.e. you cannot assign to `foo.c.im`, but you can assign a (newly created) complex number to `foo.c`.

因此，复数和向量的*元素*是不可变的。但是，持有这些类型的聚合的元素*当然可以*被修改。也就是说，你不能赋值给foo.c。但是你可以给foo.c分配一个(新创建的)复数。

The JIT compiler implements strict aliasing rules: accesses to different types do **not** alias, except for differences in signedness (this applies even to `char` pointers, unlike C99). Type punning through unions is explicitly detected and allowed.

JIT编译器实现了严格的别名规则:对不同类型的访问不使用**not**别名，除了不同的签名(这甚至适用于“char”指针，不像C99)。显式检测并允许通过联合进行类型双关语。

### Calling a cdata object

调用cdata对象

- **Constructor**: a ctype object can be called and used as a [constructor](http://luajit.org/ext_ffi_api.html#ffi_new). This is equivalent to `ffi.new(ct, ...)`, unless a `__new` metamethod is defined. The `__new` metamethod is called with the ctype object plus any other arguments passed to the contructor. Note that you have to use `ffi.new` inside of it, since calling `ct(...)` would cause infinite recursion.
- **构造函数**:可以调用ctype对象并将其用作[构造函数](http://luajit.org/ext_ffi_api.html#ffi_new)。这相当于ffi。“new(ct，…)”，除非定义了“new”元方法。使用ctype对象和传递给构造函数的任何其他参数来调用“new”元方法。注意，必须使用' ffi '。新的内部，因为调用“ct(…)”将导致无限递归。
- **C function call**: a cdata function or cdata function pointer can be called. The passed arguments are [converted to the C types](http://luajit.org/ext_ffi_semantics.html#convert_fromlua) of the parameters given by the function declaration. Arguments passed to the variable argument part of vararg C function use [special conversion rules](http://luajit.org/ext_ffi_semantics.html#convert_vararg). This C function is called and the return value (if any) is [converted to a Lua object](http://luajit.org/ext_ffi_semantics.html#convert_tolua).
- **C函数调用**:可以调用cdata函数或cdata函数指针。传递的参数[转换为C类型](http://luajit.org/ext_ffi_semantics.html#convert_fromlua)是函数声明给出的参数。使用[特殊转换规则](http://luajit.org/ext_ffi_semantics.html#convert_vararg)将参数传递给变量参数部分。调用这个C函数并将返回值(如果有的话)[转换为Lua对象](http://luajit.org/ext_ffi_semantics.html#convert_tolua)。
- On Windows/x86 systems, `__stdcall` functions are automatically detected and a function declared as `__cdecl` (the default) is silently fixed up after the first call.
- 在Windows/x86系统上，“stdcall”函数会被自动检测到，并且在第一次调用后，被声明为“cdecl”(默认值)的函数会被静默地修正。

### Arithmetic on cdata objects

cdata对象上的算法

- **Pointer arithmetic**: a cdata pointer/array and a cdata number or a Lua number can be added or subtracted. The number must be on the right hand side for a subtraction. The result is a pointer of the same type with an address plus or minus the number value multiplied by the element size in bytes. An error is raised if the element size is undefined.

- **指针算术**:一个cdata指针/数组和一个cdata数字或一个Lua数字可以添加或删除。数字必须在减法的右边。结果是一个相同类型的指针，其地址为数值乘以元素大小(以字节为单位)的加减号。如果元素大小未定义，则会引发错误。

- **Pointer difference**: two compatible cdata pointers/arrays can be subtracted. The result is the difference between their addresses, divided by the element size in bytes. An error is raised if the element size is undefined or zero.

- **指针差异**:可以减去两个兼容的cdata指针/数组。结果是它们的地址之间的差异，除以以字节为单位的元素大小。如果元素大小未定义或为零，则会引发错误。

- **64 bit integer arithmetic**: the standard arithmetic operators (`+ - * / % ^` and unary minus) can be applied to two cdata numbers, or a cdata number and a Lua number. If one of them is an `uint64_t`, the other side is converted to an `uint64_t` and an unsigned arithmetic operation is performed. Otherwise both sides are converted to an `int64_t` and a signed arithmetic operation is performed. The result is a boxed 64 bit cdata object.
   If one of the operands is an `enum` and the other operand is a string, the string is converted to the value of a matching `enum` constant before the above conversion.
   These rules ensure that 64 bit integers are "sticky". Any expression involving at least one 64 bit integer operand results in another one. The undefined cases for the division, modulo and power operators return `2LL ^ 63` or `2ULL ^ 63`.
   You'll have to explicitly convert a 64 bit integer to a Lua number (e.g. for regular floating-point calculations) with `tonumber()`. But note this may incur a precision loss.
   
- **64位整数算术**:标准算术运算符(' + - * / % ^ '和一元减)可应用于两个cdata数字，或一个cdata数字和一个Lua数字。如果其中一个是' uint64_t '，则将另一端转换为' uint64_t '并执行无符号算术运算。否则，两边将转换为' int64_t '并执行有符号的算术运算。结果是一个装箱的64位cdata对象。
  
   如果其中一个操作数是' enum '，而另一个操作数是字符串，则在进行上述转换之前，将字符串转换为匹配的' enum '常量的值。
   
   这些规则确保64位整数具有“粘性”。任何涉及至少一个64位整数操作数的表达式都会导致另一个结果。除法运算符、模运算符和幂运算符的未定义情况返回' 2LL ^ 63 '或' 2ULL ^ 63 '。
   
   您必须使用“tonumber()”显式地将64位整数转换为Lua数字(例如，用于常规浮点计算)。但是请注意，这可能会导致精度损失。

### Comparisons of cdata objects

cdata对象的比较

- **Pointer comparison**: two compatible cdata pointers/arrays can be compared. The result is the same as an unsigned comparison of their addresses. `nil` is treated like a `NULL` pointer, which is compatible with any other pointer type.

- **指针比较**:两个兼容的cdata指针/数组可以进行比较。结果与地址的无符号比较相同。' nil '被视为' NULL '指针，它与任何其他指针类型兼容。

- **64 bit integer comparison**: two cdata numbers, or a cdata number and a Lua number can be compared with each other. If one of them is an `uint64_t`, the other side is converted to an `uint64_t` and an unsigned comparison is performed. Otherwise both sides are converted to an `int64_t` and a signed comparison is performed.
   If one of the operands is an `enum` and the other operand is a string, the string is converted to the value of a matching `enum` constant before the above conversion.
   
- **64位整数比较**:两个cdata数字，或者一个cdata数字和一个Lua数字可以相互比较。如果其中一个是' uint64_t '，则将另一端转换为' uint64_t '并执行无符号比较。否则，两边将转换为' int64_t '并执行带符号的比较。
  
   如果其中一个操作数是' enum '，而另一个操作数是字符串，则在进行上述转换之前，将字符串转换为匹配的' enum '常量的值。
   
- **Comparisons for equality/inequality** never raise an error. Even incompatible pointers can be compared for equality by address. Any other incompatible comparison (also with non-cdata objects) treats the two sides as unequal.

- **相等/不等的比较**不会产生错误。甚至不兼容的指针也可以通过地址来进行比较。任何其他不兼容的比较(也与非cdata对象)都将双方视为不平等。

### cdata objects as table keys

cdata对象作为表键

Lua tables may be indexed by cdata objects, but this doesn't provide any useful semantics — **cdata objects are unsuitable as table keys!**

Lua表可能被cdata对象索引，但这并不能提供任何有用的语义—**cdata对象不适合作为表键!**

A cdata object is treated like any other garbage-collected object and is hashed and compared by its address for table indexing. Since there's no interning for cdata value types, the same value may be boxed in different cdata objects with different addresses. Thus `t[1LL+1LL]` and `t[2LL]` usually **do not** point to the same hash slot and they certainly **do not** point to the same hash slot as `t[2]`.

cdata对象被视为任何其他垃圾收集对象，并通过其表索引地址进行散列和比较。由于没有针对cdata值类型的内联，相同的值可能被装箱到具有不同地址的不同cdata对象中。因此，' t[1LL+1LL] '和' t[2LL] '通常**不会**指向相同的哈希槽，它们当然**不会**指向与' t[2] '相同的哈希槽。

It would seriously drive up implementation complexity and slow down the common case, if one were to add extra handling for by-value hashing and comparisons to Lua tables. Given the ubiquity of their use inside the VM, this is not acceptable.

如果要为Lua表的按值散列和比较添加额外的处理，则会严重增加实现的复杂性并降低常见情况下的速度。考虑到它们在VM中的普遍使用，这是不可接受的。

There are three viable alternatives, if you really need to use cdata objects as keys:

有三个可行的选择，如果你真的需要使用cdata对象作为键:

- If you can get by with the precision of Lua numbers (52 bits), then use `tonumber()` on a cdata number or combine multiple fields of a cdata aggregate to a Lua number. Then use the resulting Lua number as a key when indexing tables.
   One obvious benefit: `t[tonumber(2LL)]` **does** point to the same slot as `t[2]`.
   
- 如果您可以通过Lua数字的精度(52位)，那么在一个cdata数字上使用“tonumber()”，或者将一个cdata聚合的多个字段组合成一个Lua数字。然后在索引表时使用结果Lua编号作为键。
  
   一个明显的好处:' t[tonumber(2LL)] ' **指向与' t[2] '相同的位置。
   
- Otherwise use either `tostring()` on 64 bit integers or complex numbers or combine multiple fields of a cdata aggregate to a Lua string (e.g. with [`ffi.string()`](http://luajit.org/ext_ffi_api.html#ffi_string)). Then use the resulting Lua string as a key when indexing tables.

- 否则，在64位整数或复数上使用' tostring() '，或者将cdata聚合的多个字段合并为一个Lua字符串(例如，用[' ffi.string() '](http://luajit.org/ext_ffi_api.html#ffi_string))。然后在索引表时使用结果Lua字符串作为键。

- Create your own specialized hash table implementation using the C types provided by the FFI library, just like you would in C code. Ultimately this may give much better performance than the other alternatives or what a generic by-value hash table could possibly provide.

- 使用FFI库提供的C类型创建自己的专用散列表实现，就像在C代码中一样。最终，这可能比其他替代方法或通用的按值哈希表可能提供的性能要好得多。

## Parameterized Types

参数化类型

To facilitate some abstractions, the two functions [`ffi.typeof`](http://luajit.org/ext_ffi_api.html#ffi_typeof) and [`ffi.cdef`](http://luajit.org/ext_ffi_api.html#ffi_cdef) support parameterized types in C declarations. Note: none of the other API functions taking a cdecl allow this.

为了简化一些抽象，两个函数[' ffi.typeof '](http://luajit.org/ext_ffi_api.html#ffi_typeof)和[' ffi.cdef '](http://luajit.org/ext_ffi_api.html#ffi_cdef)支持C声明中的参数化类型。注意:其他采用cdecl的API函数都不允许这样做。

Any place you can write a **`typedef` name**, an **identifier** or a **number** in a declaration, you can write `$` (the dollar sign) instead. These placeholders are replaced in order of appearance with the arguments following the cdecl string:

在声明中可以写** ' typedef '名称**、**标识符**或**数字**的任何地方，都可以写' $ '(美元符号)。这些占位符按照出现的顺序用cdecl字符串后面的参数替换:

```
-- Declare a struct with a parameterized field type and name:
ffi.cdef([[
typedef struct { $ $; } foo_t;
]], type1, name1)

-- Anonymous struct with dynamic names:
local bar_t = ffi.typeof("struct { int $, $; }", name1, name2)
-- Derived pointer type:
local bar_ptr_t = ffi.typeof("$ *", bar_t)

-- Parameterized dimensions work even where a VLA won't work:
local matrix_t = ffi.typeof("uint8_t[$][$]", width, height)
```

Caveat: this is *not* simple text substitution! A passed ctype or cdata object is treated like the underlying type, a passed string is considered an identifier and a number is considered a number. You must not mix this up: e.g. passing `"int"` as a string doesn't work in place of a type, you'd need to use `ffi.typeof("int")` instead.

注意:这不是简单的文本替换!传递的ctype或cdata对象被视为基础类型，传递的字符串被视为标识符，数字被视为数字。你不能混淆这一点:例如，传递' ' int '作为一个字符串不工作的地方的类型，你需要使用' ffi.typeof("int") '代替。

The main use for parameterized types are libraries implementing abstract data types ([example](https://www.freelists.org/post/luajit/ffi-type-of-pointer-to,8)), similar to what can be achieved with C++ template metaprogramming. Another use case are derived types of anonymous structs, which avoids pollution of the global struct namespace.

参数化类型的主要用途是实现抽象数据类型的库([example](https://www.freelists.org/post/luajit/ffi-type-of-pointer-to,8))，类似于c++模板元编程可以实现的功能。另一个用例是匿名结构的派生类型，它避免了全局结构名称空间的污染。

Please note that parameterized types are a nice tool and indispensable for certain use cases. But you'll want to use them sparingly in regular code, e.g. when all types are actually fixed.

请注意，参数化类型是一个很好的工具，对于某些用例来说是不可或缺的。但是，在常规代码中，您应该尽量少地使用它们，例如，当所有类型都是固定的时候。

## Garbage Collection of cdata Objects

cdata对象的垃圾收集

All explicitly (`ffi.new()`, `ffi.cast()` etc.) or implicitly (accessors) created cdata objects are garbage collected. You need to ensure to retain valid references to cdata objects somewhere on a Lua stack, an upvalue or in a Lua table while they are still in use. Once the last reference to a cdata object is gone, the garbage collector will automatically free the memory used by it (at the end of the next GC cycle).

所有显式(' ffi.new() '， ' ffi.cast() '等)或隐式(访问器)创建的cdata对象都被垃圾回收。您需要确保在Lua堆栈、upvalue或Lua表中的某个地方保留对cdata对象的有效引用，而这些对象仍然在使用中。一旦cdata对象的最后一个引用消失，垃圾收集器将自动释放它所使用的内存(在下一个GC周期结束时)。

Please note that pointers themselves are cdata objects, however they are **not** followed by the garbage collector. So e.g. if you assign a cdata array to a pointer, you must keep the cdata object holding the array alive as long as the pointer is still in use:

请注意指针本身是cdata对象，但是它们不是垃圾收集器后面的对象。例如，如果你将一个cdata数组赋值给一个指针，你必须让这个cdata对象在指针还在使用的时候保持数组的活动状态:

```
ffi.cdef[[
typedef struct { int *a; } foo_t;
]]

local s = ffi.new("foo_t", ffi.new("int[10]")) -- WRONG!

local a = ffi.new("int[10]") -- OK
local s = ffi.new("foo_t", a)
-- Now do something with 's', but keep 'a' alive until you're done.
```

Similar rules apply for Lua strings which are implicitly converted to `"const char *"`: the string object itself must be referenced somewhere or it'll be garbage collected eventually. The pointer will then point to stale data, which may have already been overwritten. Note that *string literals* are automatically kept alive as long as the function containing it (actually its prototype) is not garbage collected.

类似的规则也适用于Lua字符串，它被隐式地转换为“const char *”:字符串对象本身必须在某个地方被引用，否则它最终将被垃圾收集。指针将指向过时的数据，这些数据可能已经被覆盖了。注意，只要包含它的函数(实际上是它的原型)没有被垃圾回收，*string literal *就会自动保持活动状态。

Objects which are passed as an argument to an external C function are kept alive until the call returns. So it's generally safe to create temporary cdata objects in argument lists. This is a common idiom for [passing specific C types to vararg functions](http://luajit.org/ext_ffi_semantics.html#convert_vararg).

作为参数传递给外部C函数的对象将一直保持活动状态，直到调用返回。所以在参数列表中创建临时cdata对象通常是安全的。这是一个常见的习惯用法，用于[将特定的C类型传递给vararg函数](http://luajit.org/ext_ffi_semantics.html#convert_vararg)。

Memory areas returned by C functions (e.g. from `malloc()`) must be manually managed, of course (or use [`ffi.gc()`](http://luajit.org/ext_ffi_api.html#ffi_gc)). Pointers to cdata objects are indistinguishable from pointers returned by C functions (which is one of the reasons why the GC cannot follow them).

当然，C函数返回的内存区域(例如从' malloc() ')必须手动管理(或使用[' ffi.gc() '](http://luajit.org/ext_ffi_api.html#ffi_gc))。指向cdata对象的指针与C函数返回的指针没有区别(这是GC不能遵循它们的原因之一)。

## Callbacks

回调

The LuaJIT FFI automatically generates special callback functions whenever a Lua function is converted to a C function pointer. This associates the generated callback function pointer with the C type of the function pointer and the Lua function object (closure).

每当Lua函数转换为C函数指针时，LuaJIT FFI自动生成特殊的回调函数。这将生成的回调函数指针与函数指针的C类型和Lua函数对象(闭包)相关联。

This can happen implicitly due to the usual conversions, e.g. when passing a Lua function to a function pointer argument. Or you can use `ffi.cast()` to explicitly cast a Lua function to a C function pointer.

由于通常的转换，例如在将Lua函数传递给函数指针参数时，这可能会隐式地发生。或者可以使用' ffi.cast() '来显式地将Lua函数转换为C函数指针。

Currently only certain C function types can be used as callback functions. Neither C vararg functions nor functions with pass-by-value aggregate argument or result types are supported. There are no restrictions for the kind of Lua functions that can be called from the callback — no checks for the proper number of arguments are made. The return value of the Lua function will be converted to the result type and an error will be thrown for invalid conversions.

目前，只有某些C函数类型可以用作回调函数。既不支持C变量函数，也不支持带有按值传递聚合参数或结果类型的函数。对于可以从回调中调用的Lua函数的类型没有限制—不会检查参数的正确数量。Lua函数的返回值将被转换为结果类型，对于无效的转换将抛出一个错误。

It's allowed to throw errors across a callback invocation, but it's not advisable in general. Do this only if you know the C function, that called the callback, copes with the forced stack unwinding and doesn't leak resources.

允许在回调调用中抛出错误，但通常不建议这样做。只有在您知道调用回调的C函数能够处理强制堆栈解压缩且不会泄漏资源的情况下，才可以这样做。

One thing that's not allowed, is to let an FFI call into a C function get JIT-compiled, which in turn calls a callback, calling into Lua again. Usually this attempt is caught by the interpreter first and the C function is blacklisted for compilation.

有一件事是不允许的，那就是让对C函数的FFI调用得到jit编译，然后调用回调，再次调用Lua。通常，解释器会首先捕获这个尝试，然后将C函数列入黑名单进行编译。

However, this heuristic may fail under specific circumstances: e.g. a message polling function might not run Lua callbacks right away and the call gets JIT-compiled. If it later happens to call back into Lua (e.g. a rarely invoked error callback), you'll get a VM PANIC with the message `"bad callback"`. Then you'll need to manually turn off JIT-compilation with [`jit.off()`](http://luajit.org/ext_jit.html#jit_onoff_func) for the surrounding Lua function that invokes such a message polling function (or similar).

但是，在特定情况下，这种启发式可能会失败:例如，消息轮询函数可能不会立即运行Lua回调，而调用会被jit编译。如果它稍后调用回Lua(例如一个很少调用的错误回调)，您将得到一个VM恐慌消息“bad callback”。然后需要使用[' jit.off() '](http://luajit.org/ext_jit.html#jit_onoff_func)手动关闭jit编译，以获得调用消息轮询功能(或类似功能)的Lua函数。

### Callback resource handling

回调资源处理

Callbacks take up resources — you can only have a limited number of them at the same time (500 - 1000, depending on the architecture). The associated Lua functions are anchored to prevent garbage collection, too.

回调会占用资源——同一时间只能有有限数量的回调(500 - 1000个，取决于体系结构)。关联的Lua函数也被锚定以防止垃圾收集。

**Callbacks due to implicit conversions are permanent!** There is no way to guess their lifetime, since the C side might store the function pointer for later use (typical for GUI toolkits). The associated resources cannot be reclaimed until termination:

**隐式转换导致的回调是永久的!**无法猜测它们的生存期，因为C端可能存储函数指针供以后使用(通常用于GUI工具包)。相关资源在终止前不能回收:

```
ffi.cdef[[
typedef int (__stdcall *WNDENUMPROC)(void *hwnd, intptr_t l);
int EnumWindows(WNDENUMPROC func, intptr_t l);
]]

-- Implicit conversion to a callback via function pointer argument.
local count = 0
ffi.C.EnumWindows(function(hwnd, l)
  count = count + 1
  return true
end, 0)
-- The callback is permanent and its resources cannot be reclaimed!
-- Ok, so this may not be a problem, if you do this only once.
```

Note: this example shows that you *must* properly declare `__stdcall` callbacks on Windows/x86 systems. The calling convention cannot be automatically detected, unlike for `__stdcall` calls *to* Windows functions.

注意:这个例子表明您*必须*正确地在Windows/x86系统上声明' stdcall '回调。调用约定不能被自动检测到，不像“调用”*到* Windows函数。

For some use cases it's necessary to free up the resources or to dynamically redirect callbacks. Use an explicit cast to a C function pointer and keep the resulting cdata object. Then use the [`cb:free()`](http://luajit.org/ext_ffi_api.html#callback_free) or [`cb:set()`](http://luajit.org/ext_ffi_api.html#callback_set) methods on the cdata object:

对于某些用例，需要释放资源或动态重定向回调。使用对C函数指针的显式强制转换，并保留结果cdata对象。然后在cdata对象上使用[' cb:free() ' (http://luajit.org/ext_ffi_api.html#callback_free)或[' cb:set() '](http://luajit.org/ext_ffi_api.html#callback_set)方法:

```
-- Explicitly convert to a callback via cast.
local count = 0
local cb = ffi.cast("WNDENUMPROC", function(hwnd, l)
  count = count + 1
  return true
end)

-- Pass it to a C function.
ffi.C.EnumWindows(cb, 0)
-- EnumWindows doesn't need the callback after it returns, so free it.

cb:free()
-- The callback function pointer is no longer valid and its resources
-- will be reclaimed. The created Lua closure will be garbage collected.
```

### Callback performance

回调性能

**Callbacks are slow!** First, the C to Lua transition itself has an unavoidable cost, similar to a `lua_call()` or `lua_pcall()`. Argument and result marshalling add to that cost. And finally, neither the C compiler nor LuaJIT can inline or optimize across the language barrier and hoist repeated computations out of a callback function.

**回调慢!**首先，C到Lua转换本身有一个不可避免的成本，类似于“lua_call()”或“lua_pcall()”。参数和结果编组增加了成本。最后，无论是C编译器还是LuaJIT都不能跨语言障碍进行内联或优化，也不能从回调函数中消除重复计算。

Do not use callbacks for performance-sensitive work: e.g. consider a numerical integration routine which takes a user-defined function to integrate over. It's a bad idea to call a user-defined Lua function from C code millions of times. The callback overhead will be absolutely detrimental for performance.

不要对性能敏感的工作使用回调:例如，考虑一个数值积分例程，它采用用户定义的函数进行积分。从C代码中数百万次调用用户定义的Lua函数是一个糟糕的主意。回调开销绝对不利于性能。

It's considerably faster to write the numerical integration routine itself in Lua — the JIT compiler will be able to inline the user-defined function and optimize it together with its calling context, with very competitive performance.

在Lua中编写数值积分例程本身要快得多——JIT编译器将能够内联用户定义的函数并将其与调用上下文一起进行优化，具有非常好的性能。

As a general guideline: **use callbacks only when you must**, because of existing C APIs. E.g. callback performance is irrelevant for a GUI application, which waits for user input most of the time, anyway.

一般原则是:**只在必须**时使用回调，因为存在C api。例如，回调性能与GUI应用程序无关，因为GUI应用程序大部分时间都在等待用户输入。

For new designs **avoid push-style APIs**: a C function repeatedly calling a callback for each result. Instead **use pull-style APIs**: call a C function repeatedly to get a new result. Calls from Lua to C via the FFI are much faster than the other way round. Most well-designed libraries already use pull-style APIs (read/write, get/put).

对于新设计**避免推式api **:一个C函数反复调用每个结果的回调。相反，**使用pull-style api **:重复调用C函数以获得新结果。通过FFI从Lua到C的调用要比通过FFI从Lua到C的调用快得多。大多数设计良好的库已经使用了拉式api(读/写、获取/放置)。

## C Library Namespaces

C库名称空间

A C library namespace is a special kind of object which allows access to the symbols contained in shared libraries or the default symbol namespace. The default [`ffi.C`](http://luajit.org/ext_ffi_api.html#ffi_C) namespace is automatically created when the FFI library is loaded. C library namespaces for specific shared libraries may be created with the [`ffi.load()`](http://luajit.org/ext_ffi_api.html#ffi_load) API function.

C库名称空间是一种特殊的对象，它允许访问共享库中包含的符号或默认符号名称空间。默认的[' FFI . c '](http://luajit.org/ext_ffi_api.html#ffi_C)命名空间是在加载FFI库时自动创建的。可以使用[' ffi.load() '](http://luajit.org/ext_ffi_api.html#ffi_load) API函数创建特定共享库的C库名称空间。

Indexing a C library namespace object with a symbol name (a Lua string) automatically binds it to the library. First the symbol type is resolved — it must have been declared with [`ffi.cdef`](http://luajit.org/ext_ffi_api.html#ffi_cdef). Then the symbol address is resolved by searching for the symbol name in the associated shared libraries or the default symbol namespace. Finally, the resulting binding between the symbol name, the symbol type and its address is cached. Missing symbol declarations or nonexistent symbol names cause an error.

使用符号名(Lua字符串)索引C库名称空间对象时，会自动将其绑定到库。首先解析符号类型——它必须用[' ffi.cdef '](http://luajit.org/ext_ffi_api.html#ffi_cdef)声明。然后，通过在关联的共享库或默认符号名称空间中搜索符号名称来解析符号地址。最后，缓存符号名称、符号类型及其地址之间的结果绑定。缺少符号声明或不存在符号名称将导致错误。

This is what happens on a **read access** for the different kinds of symbols:

这是发生在**读访问**的不同类型的符号:

- External functions: a cdata object with the type of the function and its address is returned.

  -外部函数:返回带有函数类型和地址的cdata对象。

- External variables: the symbol address is dereferenced and the loaded value is [converted to a Lua object](http://luajit.org/ext_ffi_semantics.html#convert_tolua) and returned.

  -外部变量:取消引用符号地址，加载的值[转换为Lua对象](http://luajit.org/ext_ffi_semantics.html#convert_tolua)并返回。

- Constant values (`static const` or `enum` constants): the constant is [converted to a Lua object](http://luajit.org/ext_ffi_semantics.html#convert_tolua) and returned.

  -常量值(' static const '或' enum '常量):常量被[转换成Lua对象](http://luajit.org/ext_ffi_semantics.html#convert_tolua)并返回。

This is what happens on a **write access**:

这是发生在**写访问**:

- External variables: the value to be written is [converted to the C type](http://luajit.org/ext_ffi_semantics.html#convert_fromlua) of the variable and then stored at the symbol address.

  外部变量:将写入的值[转换为C类型](http://luajit.org/ext_ffi_semantics.html#convert_fromlua)，然后存储在符号地址。

- Writing to constant variables or to any other symbol type causes an error, like any other attempted write to a constant location.

  写入常量变量或任何其他符号类型都会导致错误，就像其他写入常量位置的尝试一样。

C library namespaces themselves are garbage collected objects. If the last reference to the namespace object is gone, the garbage collector will eventually release the shared library reference and remove all memory associated with the namespace. Since this may trigger the removal of the shared library from the memory of the running process, it's generally *not safe* to use function cdata objects obtained from a library if the namespace object may be unreferenced.

C库名称空间本身就是垃圾收集对象。如果名称空间对象的最后一个引用消失了，垃圾收集器将最终释放共享库引用并删除与名称空间关联的所有内存。因为这可能会导致共享库从正在运行的进程的内存中删除，所以如果名称空间对象可能没有被引用，那么使用从库中获得的函数cdata对象通常是“不安全的”。

Performance notice: the JIT compiler specializes to the identity of namespace objects and to the strings used to index it. This effectively turns function cdata objects into constants. It's not useful and actually counter-productive to explicitly cache these function objects, e.g. `local strlen = ffi.C.strlen`. OTOH it *is* useful to cache the namespace itself, e.g. `local C = ffi.C`.

性能注意:JIT编译器专门处理名称空间对象的标识和用于索引它的字符串。这有效地将函数cdata对象转换为常量。显式地缓存这些函数对象并不有用，而且实际上会适得其反。' local strlen = ffi.C.strlen '。缓存名称空间本身*是*有用的，例如。“local C = ffi.C”。

## No Hand-holding!

没有牵手!

The FFI library has been designed as **a low-level library**. The goal is to interface with C code and C data types with a minimum of overhead. This means **you can do anything you can do from C**: access all memory, overwrite anything in memory, call machine code at any memory address and so on.

FFI库被设计为一个低级库。目标是用最少的开销与C代码和C数据类型进行接口。这意味着**你可以从C**做任何事情:访问所有内存，覆盖内存中的任何东西，在任何内存地址调用机器码等等。

The FFI library provides **no memory safety**, unlike regular Lua code. It will happily allow you to dereference a `NULL` pointer, to access arrays out of bounds or to misdeclare C functions. If you make a mistake, your application might crash, just like equivalent C code would.

与常规的Lua代码不同，FFI库提供了**无内存安全**。它将很高兴地允许您取消对一个“空”指针的引用，在界限外访问数组或错误声明C函数。如果出错，应用程序可能会崩溃，就像C代码一样。

This behavior is inevitable, since the goal is to provide full interoperability with C code. Adding extra safety measures, like bounds checks, would be futile. There's no way to detect misdeclarations of C functions, since shared libraries only provide symbol names, but no type information. Likewise there's no way to infer the valid range of indexes for a returned pointer.

这种行为是不可避免的，因为其目标是提供与C代码的完全互操作性。增加额外的安全措施，比如边界检查，将是徒劳的。无法检测C函数的错误声明，因为共享库只提供符号名，没有类型信息。同样，也没有办法推断返回指针的有效索引范围。

Again: the FFI library is a low-level library. This implies it needs to be used with care, but it's flexibility and performance often outweigh this concern. If you're a C or C++ developer, it'll be easy to apply your existing knowledge. OTOH writing code for the FFI library is not for the faint of heart and probably shouldn't be the first exercise for someone with little experience in Lua, C or C++.

同样:FFI库是一个低级库。这意味着需要谨慎地使用它，但是它的灵活性和性能常常超过了这种关注。如果您是C或c++开发人员，应用您现有的知识将很容易。OTOH为FFI库编写代码不适合胆小的人，对于缺乏Lua、C或c++经验的人来说，这可能不是第一个练习。

As a corollary of the above, the FFI library is **not safe for use by untrusted Lua code**. If you're sandboxing untrusted Lua code, you definitely don't want to give this code access to the FFI library or to *any* cdata object (except 64 bit integers or complex numbers). Any properly engineered Lua sandbox needs to provide safety wrappers for many of the standard Lua library functions — similar wrappers need to be written for high-level operations on FFI data types, too.

作为上述的一个推论，FFI库对于不受信任的Lua代码**来说是不安全的。如果您正在对不受信任的Lua代码进行沙箱化，那么您肯定不希望让这段代码访问FFI库或*任何* cdata对象(64位整数或复数除外)。任何经过适当设计的Lua沙箱都需要为许多标准Lua库函数提供安全包装器——对于FFI数据类型的高级操作也需要编写类似的包装器。

## Current Status

当前的状态

The initial release of the FFI library has some limitations and is missing some features. Most of these will be fixed in future releases.

FFI库的最初版本有一些限制，并且缺少一些特性。其中大部分将在未来的版本中修复。

[C language support](http://luajit.org/ext_ffi_semantics.html#clang) is currently incomplete:

[C语言支持](http://luajit.org/ext_ffi_semantics.html#clang)目前还不完整:

- C declarations are not passed through a C pre-processor, yet.

  C声明还没有通过C预处理器传递。

- The C parser is able to evaluate most constant expressions commonly found in C header files. However it doesn't handle the full range of C expression semantics and may fail for some obscure constructs.

  C解析器能够计算在C头文件中常见的大多数常量表达式。但是，它不能处理所有的C表达式语义，并且可能会因为一些模糊的构造而失败。

- `static const` declarations only work for integer types up to 32 bits. Neither declaring string constants nor floating-point constants is supported.

  `静态const`声明只适用于32位以内的整数类型。既不支持声明字符串常量，也不支持浮点常量。

- Packed `struct` bitfields that cross container boundaries are not implemented.

  未实现跨容器边界的打包`结构`位域。

- Native vector types may be defined with the GCC `mode` or `vector_size` attribute. But no operations other than loading, storing and initializing them are supported, yet.

  本机向量类型可以使用GCC ` mode `或` vector_size `属性定义。但是除了加载、存储和初始化之外，还不支持其他操作。

- The `volatile` type qualifier is currently ignored by compiled code.

  `volatile`类型限定符目前被编译后的代码忽略。

- [`ffi.cdef`](http://luajit.org/ext_ffi_api.html#ffi_cdef) silently ignores most re-declarations. Note: avoid re-declarations which do not conform to C99. The implementation will eventually be changed to perform strict checks.

  [` ffi.cdef `](http://luajit.org/ext_ffi_api.html#ffi_cdef)会默默地忽略大多数重新声明。注意:避免重复声明不符合C99。最终将更改实现以执行严格的检查。

The JIT compiler already handles a large subset of all FFI operations. It automatically falls back to the interpreter for unimplemented operations (you can check for this with the [`-jv`](http://luajit.org/running.html#opt_j) command line option). The following operations are currently not compiled and may exhibit suboptimal performance, especially when used in inner loops:

JIT编译器已经处理了所有FFI操作的一个大子集。对于未实现的操作，它会自动返回到解释器(您可以使用[' -jv '](http://luajit.org/running.html#opt_j)命令行选项进行检查)。以下操作目前没有编译，可能表现出次优性能，特别是在内部循环中使用:

- Bitfield accesses and initializations.

  位域访问和初始化。

- Vector operations.

  向量操作。

- Table initializers.

  表的初始化。

- Initialization of nested `struct`/`union` types.

  嵌套的' struct ' / ' union '类型的初始化。

- Allocations of variable-length arrays or structs.

  可变长度数组或结构的分配。

- Allocations of C types with a size > 128 bytes or an alignment > 8 bytes.

  大小为> 128字节或对齐为> 8字节的C类型的分配。

- Conversions from lightuserdata to `void *`.

  从lightuserdata到`void *`的转换。

- Pointer differences for element sizes that are not a power of two.

  元素大小不是2的幂的指针差异。

- Calls to C functions with aggregates passed or returned by value.

  调用具有按值传递或返回聚合的C函数。

- Calls to ctype metamethods which are not plain functions.

  调用非普通函数的ctype元方法。

- ctype `__newindex` tables and non-string lookups in ctype `__index` tables.

  ctype ` newindex `表和非字符串查找在ctype ` index `表。

- `tostring()` for cdata types.

  ` tostring() `用于cdata类型。

- Calls to `ffi.cdef()`, `ffi.load()` and `ffi.metatype()`.

  调用`ffi.cdef()`、`ffi.load()`和`ffi.metatype()`。

Other missing features:

其他缺失的特点:

- Bit operations for 64 bit types.

  64位类型的位操作。

- Arithmetic for `complex` numbers.

  `复数`的算术运算。

- Passing structs by value to vararg C functions.

  通过值将结构传递给vararg C函数。

- [C++ exception interoperability](http://luajit.org/extensions.html#exceptions) does not extend to C functions called via the FFI, if the call is compiled.

  如果调用被编译，[c++异常互操作性](http://luajit.org/extensions.html#exceptions)不会扩展到通过FFI调用的C函数。