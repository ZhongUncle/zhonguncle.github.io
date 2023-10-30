---
layout: article
category: Assembly
date: 2023-10-30
title: macOS Assembly Guide
---
<!-- excerpt-start -->
Since most of the resources, methods and tools for learning assembly are based for Windows. So here I will introduce some materials and tools for macOS

I will continuously update this article and also using it as a personal note.

## Why you need to learn assembly (How to use it)
Assembly is the "magic" of computers. You can be a fine “warrior” who only uses high-level languages, but if you “enchant” your “weapon” with assembly, your combat effectiveness will increase greatly (of course, there are also risks of “playing with fire and burning yourself”).

Today, there are several ways to use assembly:

 - Directly use instructions of computer to write the program and use the assembler to assemble the program (this may be just for education, rarely used in actual situations, it's too complicated).
 - Used in C code to improve performance and speed, or to implement some special functions. For example, the assembly code in UNIX and Linux source codes is to improve the running speed, otherwise it can be written in pure C language; and Apple did not allow developers to obtain the CPU frequency on iOS platform, some developers used assembly code in Objective-C code instructions to infer CPU frequency.
 - can understand the decompiled content (this is generally not used by regular programmers).

> Note 1: However, Apple later added a conversion that made the estimation very inaccurate, rendering this kind of app useless.

> Note 2: Objective-C is a superset of the C language, just like C++ is also a superset of the C language. They all belong to the C language family. Before Apple use Swift, the development of Apple platforms relied entirely on Objective-C.

Now, assembly is not the threshold of programming, it's a required course to become a master. However, novices are still advised to learn C language first before contacting assembly ("learned" means being able to understand various structures and concepts).

## References and Resources
Today, there are many high-level and script languages, assembly language is becoming more and more unpopular because it is cumbersome, complex and has extremely high learning costs. For example, the Intel CPU development manual has 5,000 pages (and it will be updated every time a new gengeration is released).

### Mac OS X Assembler Guide
The first recommendation is Apple’s official assembly guide: "Mac OS X Assembler Guide", the download address is at [http://personal.denison.edu/~bressoud/cs281-s07/Assembler.pdf](http://personal.denison.edu/~bressoud/cs281-s07/Assembler.pdf). 

This guide covers the use of Mac OS X assembler `as`, assembly instructions, address modes and more. But it's not only about Intel CPU, but also about earlier Power PC. Since the latest version of this guide is from 2005, Intel's instructions have a huge update, such as AVX. And now Apple is already switching to Apple silicon(interestingly, the latest update time of manual of `as` is 2020-6-23, which is the day of the M1 released).

### Introduction to x64 Assembly
The second recommendation is Intel's ["Introduction to x64 Assembly"](https://www.intel.com/content/dam/develop/external/us/en/documents/introduction-to-x64-assembly-181178 .pdf), this is a short introduction to assembly. It's friendly for newbies or beginner.

### Intel® 64 and IA-32 Architectures Software Developer Manuals
The third one is Intel's development manual: Intel® 64 and IA-32 Architectures Software Developer Manuals.

Although this manual is very long, it is a very good information and is updated frequently. If you need to understand the new Intel instructions, it must be read. 

You can directly [Download the bound volume](https://cdrdv2.intel.com/v1/dl/getContent/671200) as an archive, but this is inconvenient to read. (Intel used to provide paper copies for free, as long as you sent an email and provided your address. Many people ordered, but most of them used to up monitor or left them in the dust. Now Intel no longer provides this benefit, which is a pity)

The Volume 1 is a general introduction, about the development history and differences of Intel CPU. If you are a beginner, you can take a look. You may be read Volume 2 frequently, it's about instructions. **The specific differences can be seen in the interface in the [Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)。**

Note that although Intel is often said to updating slowly and liitle, Intel almost every generation will have instructions or registers updates and changes. So the document update frequency is relatively high, if you need to use the latest instructions, then please update your stored documents in time.

### ARM Assembly Documents
The fourth recommendation is a set of documents about ARM assembly.
Because Mac is now switching to the self-developed M1 chip, which is based on ARM architecture and ARM does not currently provide entire assembly guidelines like Intel. The latest entire guidelines is [《ARM ® DeveloperSuite Assembler Guide Version 1.2》](https://developer.arm.com/documentation/dui0068/b) in 2001, if you are a beginner, please read this first.

If you want to learn newest instruction, it's here: [https://developer.arm.com/architectures/instruction-sets](https://developer.arm.com/architectures/instruction-sets)

## Introduction to assembler and Utilities

> Assembler and compiler are different. If you don't understand, simply think that the assembler converts assembly instructions into programs; the compiler converts high-level language codes (such as C/C++, Java) into programs.

Here is an introduction to the assembler and the utilities (including editors) that may be used.

### as
The assembler `as` for Mac OS X needs to be used in "Terminal", similar to `masm` in Windows. Supports assembly for Intel and Power PC processors. It's in the `/usr/bin/as` directory. There is an introduction to how to use it in the "Mac OS X Assembler Guide".

### ld
`ld` is a linker.

### clang
clang can be a assemble and preprocess C or other languages code to assembly code, you can see details in here: [《clang 如何产生汇编代码文件》](https://blog.csdn.net/qq_33919450/article/details/124358476)。Clang maybe make you use assembly easilier.

### gcc
We don't talk about the specific differences between `gcc` and `clang`. `gcc` has flag `-nostartfiles` ignore the linked standard library files and initialization behavior. Because sometimes you don't need to connect the C standard library and just assemble it directly. I will make a demonstration at the end.

### size
`size` will output the size of sections, like:

![`size` output](/assets/images/e3de2338d8054a01b7be017cc5fe5880.png)

### otool
`otool` can check size and content of some section, like `debug.exe` on Windows. For example, let's check content of `__TEXT,__text`:

![otool check size and content`__TEXT,__text`](/assets/images/03f673d8ac154d5fa4f67be59e28b960.png)

You also can use `otool` to check other sections, format is:

```
$ otool -v -s __TEXT __cstring a.out
a.out:
Contents of (__TEXT,__cstring) section
0000000000000025  hello world!\n
```

### Xcode
Xcode is Apple development IDE, it not only have GUI application, but also have some CLI utilities. It can write C/C++, Objective-C and Swift code, you also can develop app or programs with some assembly codes.

![write assembly code in Xcode](/assets/images/ecd23a611ef7430eb8c667d0e9676718.png)

## Syntax differences
Many people may know some assembly, but probably Windows based. But the style and syntax in Mac OS X or C language is different. 

Apple `as` or GCC, clang use AT&T assembly style. Windows MASM or NASM use Intel assembly style. Let’s talk about differences.

### Register
If you use clang or gcc to assemble it in C language or other situations, rather than in `as`, then you don't need to this section.

In Windows and C assembly syntax, register names are written directly, such as `mov ax,2`. But in `as` AT&T style, avoiding to be confused with the identifier (actually, it often be called as variable), you need to add the percent sign `%` before the register, such as `mov %ax,2`. And all registers must be written in **lowercase letters**, not case-insensitive like in Windows or C.

### Hex format
In Windows, hexadecimal numbers are written ending in `H` or `h`, for example `5c0dH`. But in Mac OS X, it needs to be written starting with `0x`, such as `0x1234`. In C language, both are fine.


## Let’s write a Hello World in assembly!

### Write code
I will give the complete code at the end, but now I explain it step by step.

At the beginning, create a file `helloworld.s`. The suffix of the assembly code file is usually `.asm` or `.s`. Now you can write the first part.

First, you need to specify **executable command**:

```
.section	__TEXT,__text,regular,pure_instructions
```

Then specify the target platform and version:

```
.build_version macos, 12, 0	sdk_version 12, 1
```

Create a new external symbol name `_main` to be the entry of the program, just like a C language program must have a `main()` function. Note that the underscore cannot be omitted.

```
.globl	_main                           ## -- Begin function main
```

Use the align command to move the position counter to the next boundary `4, 0x90` (usually an address).

```
.p2align	4, 0x90
```

Finally, we can start writing the code in `_main` part. It also means writing `main()` function:

```
_main:                                  ## @main
	.cfi_startproc					 ##Indicates the beginning of the function. Will initialize some internal data structures and issue architecture-dependent initial CFI instructions
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	leaq	L_.str(%rip), %rdi
	movb	$0, %al
	callq	_printf
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbp
	retq
	.cfi_endproc				##end function
```

There are some cfi instructions. You can find more informations in: [https://web.mit.edu/rhel-doc/3/rhel-as-en-3/cfi-directives.html](https://web.mit.edu/rhel-doc/3/rhel-as-en-3/cfi-directives.html)

In addition, CFA is the Canonical Frame Address. Related information can be found here: [
https://www.keil.com/support/man/docs/armasm/armasm_dom1361290010153.htm](https://www.keil.com/support/man/docs/armasm/armasm_dom1361290010153.htm)

Let’s start the second part **The string contained in the executable command**:

```
.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"hello world!\n"
```

Here is the string to be output: `hello world!\n`. If you use the `.ascii` command, rather than `.asciz`, then this line should be changed to `.ascii "hello world!\n\0"`, because `.asciz` automatically adds `\0` at the end of the string. If write in a C program, use `.asciz`.

At the end, you can add this line:

```
.subsections_via_symbols
```

This will tell the static link editor how many pieces this part of object file can be divided into. However, it doesn’t matter whether it is used here or not, it does not affect the results. You can add it for rigor.

The full source code is:

```
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0	sdk_version 12, 1
	.globl	_main                           ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
    .cfi_startproc                     ## Indicates the beginning of the function. Will initialize some internal data structures and issue architecture-dependent initial CFI instructions
## %bb.0:
    pushq    %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register %rbp
    subq    $16, %rsp
    movl    $0, -4(%rbp)
    leaq    L_.str(%rip), %rdi
    movb    $0, %al
    callq    _printf
    xorl    %eax, %eax
    addq    $16, %rsp
    popq    %rbp
    retq
    .cfi_endproc                ## end function
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"hello world!\n"

.subsections_via_symbols
```

### Assemble to a executable file
In Windows, the mainstream executable file format is PE (Portable Executable File Format), and the abbreviation of "Executable" is the EXE that many people are familiar with. In macOS, executable files are called "Mach-O executable files".

If you use `file` to check a Mach-O executable file, you can see someting like below. Here let's check Xcode:

```
$ file /Applications/Xcode.app/Contents/MacOS/Xcode 
Xcode: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64:Mach-O 64-bit executable arm64]
Xcode (for architecture x86_64):	Mach-O 64-bit executable x86_64
Xcode (for architecture arm64):	Mach-O 64-bit executable arm64
```

So the finally you need to convert `hello.s` to a Mach-O executable file.

There are two methods:
#### Method 1
Since this program is very simple and does not link to any special libraries, you can directly use the following command:

```
$ gcc -nostartfiles helloworld.s
$ chmod 755 a.out
$ file a.out 
a.out: Mach-O 64-bit executable x86_64
```

Now you can see `a.out` is our `Mach-O executable file` needed。

Run it: 

```
$ ./a.out 
hello world!
```

Very nice.

#### Method 2
This is common method. First use `as` to assemble the code and modify the permissions:

```
$ as hello.s
$ chmod 755 a.out 
```

**You need to notice `as` will generate Mach-O object file, rather than `Mach-O executable file`. `Mach-O executable file` can not run, it will warning `cannot execute binary file`. On Windows, object file is named as COFF (Common Object File Format).**

Then use the linker `ld` to deal with object files. But if directly and simply use the `ld`, you will see:

```
$ ld a.out
Undefined symbols for architecture x86_64:
  "_printf", referenced from:
      _main in a.out
ld: symbol(s) not found for architecture x86_64
```

Because it uses `_printf` in C standard library, but `ld` can't find it directly. So, add library path is fine:

```
$ ld a.out -o hello -lSystem -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib
```

**Common `Mach-O executable file` doesn't have any suffiex**. The `hello` is `Mach-O executable file` we need. You can use `file` to check it: 

```
$ file hello
hello: Mach-O 64-bit executable x86_64
```

Run it:

```
$ ./hello
hello world!
```

Very Nice~

I hope these will help someone in need~