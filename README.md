# odin-freetype
[Odin](https://github.com/odin-lang/Odin) bindings for [FreeType](https://www.freetype.org/index.html).

Freetype Version: 2.13.2

_**Note:** This is a work in progress. If additional bindings are required, please feel free to submit an issue or a pull request._

## Installation
Clone this repository to Odin's shared collection, preferably into a directory named 'freetype'.

```bash
cd Odin/shared
git clone https://github.com/englerj/odin-freetype.git freetype
```

## Usage
Import the package.
```c
import "shared:freetype"
```

## Demo
On Windows, you can run the demo under the `demo` folder. The demo renders a series of characters from a font and displays them in the window. You can adjust the size of the font using the arrow keys.
```bash
cd demo
odin run .\
```