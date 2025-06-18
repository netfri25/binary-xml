# Binary XML encode/decode

<img src='assets/showcase.png'>

## Getting Started

#### Dependencies
 - fasm
 - make

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
cat <file-to-encode> | build/encode > <encoded-file>
```

#### Decoding
```shell
cat <file-to-decode> | build/decode > <decoded-file>
```
