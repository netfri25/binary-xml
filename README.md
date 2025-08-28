# Binary XML encode/decode

> [!IMPORTANT]
> I haven't yet updated information about performance in this branch

<img src='assets/showcase.png'>

## About
this project tries to give an answer for [embedding binary data in XML](https://stackoverflow.com/questions/19893/how-do-you-embed-binary-data-in-xml).
it uses self-closing XML tags to represent the binary data.
Hours were spent on this project to make sure that it as highly optimized as possible, and for that reason there are some [limitations](#dependencies).

### Performance
My machine contains the following:
 - Void Linux x86-64 (kernel version 6.12.41_1)
 - AMD Ryzen AI 9 365 @ 5.04 GHz (10 cores, 20 threads, L1: 800 KiB, L2: 10 MiB, L3: 24 MiB)
 - 24 GiB DDR4 RAM @ 3205 MHz
 - 1TB (953 GiB) NVME M.2 PCIe (Read 4500 MB/s, Write 3600 MB/s, Read IOPS 600K, Write IOPS 650K)


##### encoding
430ms for reading 7.1 MB and writing 365 MB.
 - read:  `16.51 MB/s`
 - write: `848.83 MB/s`

##### decoding
490ms for reading 365 MB and writing 7.1 MB
 - read:  `744.9 MB/s`
 - write: `14.45 MB/s`

> [!NOTE]
> decoding is naturally slower, since it needs to check for the correctness of the input

## Getting Started

### Dependencies
 - `x86-64` architecture
 - minimal linux version of 5.4
 - fasm
 - make
 - cpu with [avx512](https://en.wikipedia.org/wiki/AVX-512#CPUs_with_AVX-512)

###### no need for libc :)

### Example
after [building](#build) the programs, we can run the following commands to demonstrate how this format works:
```shell
echo -n "Hello World!" > hello.txt
build/encode < hello.txt > hello.xml
```

> [!IMPORTANT]
> because of mmap-ing files, reading from stdin, writing from stdout, and piping - are not possible at all, and will give an error. using this project's executables is only possible by redirecting, which creates a symlink from stdin/stdout to the redirected file, as shown in this example.

firstly, we create a `hello.txt` file with the content `Hello World!`, and by using echo's `-n` flag we ensure that it won't insert a `\n` at the end of the file.
then, we encode the content. we read from `hello.txt` and write to `hello.xml` the encoded XML.

looking into `hello.xml`, we should see the following content:
```xml
<zero/><zero/><zero/><one/><zero/><zero/><one/><zero/><one/><zero/><one/><zero/><zero/><one/><one/><zero/><zero/><zero/><one/><one/><zero/><one/><one/><zero/><zero/><zero/><one/><one/><zero/><one/><one/><zero/><one/><one/><one/><one/><zero/><one/><one/><zero/><zero/><zero/><zero/><zero/><zero/><one/><zero/><zero/><one/><one/><one/><zero/><one/><zero/><one/><zero/><one/><one/><one/><one/><zero/><one/><one/><zero/><zero/><one/><zero/><zero/><one/><one/><one/><zero/><zero/><zero/><one/><one/><zero/><one/><one/><zero/><zero/><zero/><one/><zero/><zero/><one/><one/><zero/><one/><zero/><zero/><zero/><zero/><one/><zero/><zero/>
```

this is one of the most efficient encoding methods known to mankind, and can easily compress data the other way around.

#### Build
```shell
make
```

#### Clean
```shell
make clean
```

## Usage

#### Encoding
```shell
build/encode < [file to encode] > [encoded file]
```

#### Decoding
```shell
build/decode < [file to decode] > [decoded file]
```
