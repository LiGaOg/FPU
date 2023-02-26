# FPU



## `fonecycle`接口

| I/O  | 位宽                   | 接口名            | 描述                                                         |
| ---- | ---------------------- | ----------------- | ------------------------------------------------------------ |
| `I`  | `EXPWIDTH + SIGWIDTH`  | `frs1`            | 浮点数运算第一个操作数                                       |
| `I`  | `EXPWIDTH + SIGWIDTH`  | `frs2`            | 浮点数运算第二个操作数                                       |
| `I`  | `EXPWIDTH. + SIGWIDTH` | `frs3`            | 浮点数运算第三个操作数                                       |
| `I`  | `XLEN`                 | `rs`              | 浮点数运算需要用到的整数，例如整数转浮点数                   |
| `I`  | 5                      | `ftype`           | 决定使用哪种浮点数运算，对应关系见下表                       |
| `I`  | 1                      | `fcontrol`        | 1为detect tininess after rounding，0为before rounding.       |
| `I`  | 3                      | `roundingMode`    | 代表舍入模式，具体哪种舍入模式见下表                         |
| `O`  | `EXPWIDTH + SIGWIDTH`  | `farthematic_res` | 浮点数运算的结果                                             |
| `O`  | 32                     | `w_convert_res`   | 浮点数转换后得到的32位整数                                   |
| `O`  | 64                     | `l_convert_res`   | 浮点数转换后得到的64位整数                                   |
| `O`  | 1                      | `fcompare_res`    | 浮点数比较的结果                                             |
| `O`  | `XLEN`                 | `fclass_res`      | `fclass`指令的结果                                           |
| `O`  | 5                      | `exception_flags` | 浮点数运算过程中出现的异常，异常的编码为`{invalid, infinite, overflow, underflow, inexact}` |

其中，`ftype`和浮点数运算的对应关系如下：

| `ftype` | 指令                             |
| ------- | -------------------------------- |
| 0       | `fadd.s frd, frs1, frs2`         |
| 1       | `fsub.s frd, frs1, frs2`         |
| 2       | `fmul.s frd, frs1, frs2`         |
| 3       | `fmin.s frd, frs1, frs2`         |
| 4       | `fmax.s frd, frs1, frs2`         |
| 5       | `fmadd.s frd, frs1, frs2, frs3`  |
| 6       | `fnmadd.s frd, frs1, frs2, frs3` |
| 7       | `fmsub.s frd, frs1, frs2, frs3`  |
| 8       | `fnmsub.s frd, frs1, frs2, frs3` |
| 9       | `fcvt.w.s rd, frs1`              |
| 10      | `fcvt.wu.s rd, frs1`             |
| 11      | `fcvt.l.s rd, frs1`              |
| 12      | `fcvt.lu.s rd, frs1`             |
| 13      | `fcvt.s.l frd, rs1`              |
| 14      | `fcvt.s.lu frd, rs1`             |
| 15      | `fsgnj.s frd, frs1, frs2`        |
| 16      | `fsgnjn.s frd, frs1, frs2`       |
| 17      | `fsgnjx.s frd, frs1, frs2`       |
| 18      | `feq.s rd, frs1, frs2`           |
| 19      | `flt.s rd, frs1, frs2`           |
| 20      | `fle.s rd, frs1, frs2`           |
| 21      | `fclass frs`                     |



其中，`roundingMode`的对应关系如下：

| `roundingMode` | 舍入模式                                |
| -------------- | --------------------------------------- |
| 000            | Round to nearest, ties to even          |
| 001            | Round towards zero                      |
| 010            | Round Down                              |
| 011            | Round Up                                |
| 100            | Round to Nearest, ties to Max Magnitude |



## `fonecycle` 验证


### `fadd.s`

| `frs1`值   | `frs2`值   | `frd`结果  | 描述                                                    |
| ---------- | ---------- | ---------- | ------------------------------------------------------- |
| 0x3f800000 | 0x40400000 | 0x40800000 | 1.0 + 3.0 = 4.0                                         |
| 0x40200000 | 0x3F800000 | 0x40600000 | 2.5 + 1.0 = 3.5                                         |
| 0xC49A6333 | 0x3F8CCCCD | 0xC49A4000 | -1235.1 + 1.1 = -1234.0，会触发inexact异常              |
| 0x40490FDB | 0x322BCC77 | 0x40490FDB | 3.14159265 + 0.00000001 = 3.14159265，会触发inexact异常 |



### `fsub.s`

| `frs1`     | `frs2`     | `frd`      | 描述                                 |
| ---------- | ---------- | ---------- | ------------------------------------ |
| 0x40200000 | 0x3F800000 | 0x3FC00000 | 2.5 - 1.0 = 1.5                      |
| 0xC49A6333 | 0xBF8CCCCD | 0xC49A4000 | -1235.1 - (-1.1) = -1234             |
| 0x40490FDB | 0x322BCC77 | 0x40490FDB | 3.14159265 - 0.00000001 = 3.14159265 |
| 0x7F800000 | 0x7F800000 | 0x7fc00000 | Inf-Inf = qNaN                       |




### `fmul.s`

| `frs1`     | `frs2`     | `frd`      | 描述                                    |
| ---------- | ---------- | ---------- | --------------------------------------- |
| 0x40200000 | 0x3F800000 | 0x40200000 | 2.5 x 1.0 = 2.5                         |
| 0xC49A6333 | 0xBF8CCCCD | 0x44A9D385 | -1235.1 x -1.1 = 1358.61                |
| 0x40490FDB | 0x322BCC77 | 0x3306EE2D | 3.14159265 x 0.00000001 = 3.14159265e-8 |



### `fmin.s`

| `frs1`     | `frs2`     | `frd`      | 描述                                     |
| ---------- | ---------- | ---------- | ---------------------------------------- |
| 2.5        | 1.0        | 1.0        | Min(2.5, 1.0) = 1.0                      |
| -1235.1    | 1.1        | -1235.1    | Min(-1235.1, 1.1) = -1235.1              |
| 1.1        | -1235.1    | -1235.1    | Min(1.1, -1235.1) = -1235.1              |
| NaN        | -1235.1    | -1235.1    | Min(NaN, -1235.1) = -1235.1              |
| 3.14159265 | 0.00000001 | 0.00000001 | Min(3.14159265, 0.00000001) = 0.00000001 |
| -1.0       | -2.0       | -2.0       | Min(-1.0, -2.0) = -2.0                   |
| -0.0       | 0.0        | -0.0       | Min(-0.0, 0.0) = -0.0                    |
| 0.0        | -0.0       | -0.0       | Min(0.0, -0.0) = -0.0                    |



### `fmax.s`
| `frs1`     | `frs2`     | `frd`      | 描述                                     |
| ---------- | ---------- | ---------- | ---------------------------------------- |
| 2.5        | 1.0        | 2.5        | Max(2.5, 1.0) = 2.5                      |
| -1235.1    | 1.1        | 1.1        | Max(-1235.1, 1.1) = 1.1                  |
| 1.1        | -1235.1    | 1.1        | Max(1.1, -1235.1) = 1.1                  |
| NaN        | -1235.1    | -1235.1    | Max(NaN, -1235.1) = -1235.1              |
| 3.14159265 | 0.00000001 | 3.14159265 | Max(3.14159265, 0.00000001) = 3.14159265 |
| -1.0       | -2.0       | -1.0       | Max(-1.0, -2.0) = -1.0                   |
| sNaNf      | 1.0        | 1.0        | Max(sNaNf, 1.0) = 1.0                    |
| NaN        | NaN        | qNaNf      | Max(NaN, NaN) = qNaNf                    |
| -0.0       | 0.0        | 0.0        | Max(-0.0, 0.0) = 0.0                     |
| 0.0        | -0.0       | 0.0        | Max(0.0, -0.0) = 0.0                     |


### `fmadd.s`

| `frs1` | `frs2`  | `frs3` | `frd`  | 描述                          |
| ------ | ------- | ------ | ------ | ----------------------------- |
| 1.0    | 2.5     | 1.0    | 3.5    | 1.0 x 2.5 + 1.0 = 3.5         |
| -1.0   | -1235.1 | 1.1    | 1236.2 | -1.0 x -1235.1 + 1.1 = 1236.2 |
| 2.0    | -5.0    | -2.0   | -12.0  | 2.0 x -5.0 + -2.0 = -12.0     |



### `fnmsub.s`

| `frs1` | `frs2`  | `frs3` | `frd` | 描述                            |
| ------ | ------- | ------ | ----- | ------------------------------- |
| 1.0    | 2.5     | 1.0    | -1.5  | -(1.0 x 2.5) + 1.0 = -1.5       |
| -1.0   | -1235.1 | 1.1    | -1234 | -(-1.0 x -1235.1) + 1.1 = -1234 |
| 2.0    | -5.0    | -2.0   | 8.0   | -(2.0 x -5.0) + -2.0 = 8.0      |

### `fmsub.s`

| `frs1` | `frs2`  | `frs3` | `frd` | 描述                        |
| ------ | ------- | ------ | ----- | --------------------------- |
| 1.0    | 2.5     | 1.0    | 1.5   | 1.0 x 2.5 - 1.0 = 1.5       |
| -1.0   | -1235.1 | 1.1    | 1234  | -1.0 x -1235.1 - 1.1 = 1234 |
| 2.0    | -5.0    | -2.0   | -8.0  | 2.0 x -5.0 -( -2.0) = -8.0  |

### `fnmadd.s`

| `frs1` | `frs2`  | `frs3` | `frd`   | 描述                             |
| ------ | ------- | ------ | ------- | -------------------------------- |
| 1.0    | 2.5     | 1.0    | -3.5    | -(1.0 x 2.5) - 1.0 = 3.5         |
| -1.0   | -1235.1 | 1.1    | -1236.2 | -(-1.0 x -1235.1) - 1.1 = 1236.2 |
| 2.0    | -5.0    | -2.0   | 12.0    | -(2.0 x -5.0) -( -2.0) = -12.0   |

### `fcvt.w.s`



### `fcvt.wu.s`



### `fcvt.l.s`



### `fcvt.lu.s`



### `fcvt.s.l`



### `fcvt.s.lu`



### `fsgnj.s`



### `fsgnjn.s`



### `fsgnjx.s`



### `feq.s`



### `flt.s`



### `fle.s`



### `fclass`



## `fdivsqrt`验证



### `fdiv.s`



### `fsqrt.s`



## 几点注意

* `roundingMode`中，hardfloat在roundingMode为110的时候，还能够进行舍入，但是在RISC-V中，110没有用，111需要动态按照指令选择舍入，注意。
* 
