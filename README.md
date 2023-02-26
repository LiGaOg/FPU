# FPU

FPU与qemu进行差分测试，测试数据来源于isa test以及benchmark



## `fonecycle`接口



## `fonecycle` 验证

`fadd.s frd, frs1, frs2`

#### 正常运算

| `frs1`值   | `frs2`值   | `frd`结果  | 描述                                 |
| ---------- | ---------- | ---------- | ------------------------------------ |
| 0x3f800000 | 0x40400000 | 0x40800000 | 1.0 + 3.0 = 4.0                      |
| 0x40200000 | 0x3F800000 | 0x40600000 | 2.5 + 1.0 = 3.5                      |
| 0xC49A6333 | 0x3F8CCCCD | 0xC49A4000 | -1235.1 + 1.1 = -1234.0              |
| 0x40490FDB | 0x322BCC77 | 0x40490FDB | 3.14159265 + 0.00000001 = 3.14159265 |

#### 会导致overflow异常

| `frs1`值   | `frs2`值   | `frd`结果 | 描述 |
| ---------- | ---------- | --------- | ---- |
| 0x43000000 | 0x43000000 | Overflow  |      |
| 0x42c00000 | 0x42c00000 | Overflow  |      |
| 0x41800000 | 0x41800000 | Overflow  |      |
| 0x7f000000 | 0x7f000000 | Overflow  |      |
| 0xff000000 | 0xff000000 | Overflow  |      |
|            |            |           |      |
|            |            |           |      |



#### 会导致underflow异常



#### 会导致invalid operation异常



## `fdivsqrt`验证



## 几点注意

* `roundingMode`中，hardfloat在roundingMode为110的时候，还能够进行舍入，但是在RISC-V中，110没有用，111需要动态按照指令选择舍入，注意。
* 
