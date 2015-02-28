# TermStyle [![Dependencies](https://david-dm.org/rodw/termstyle.svg)](https://npmjs.org/package/termstyle) [![NPM version](https://badge.fury.io/js/termstyle.svg)](http://badge.fury.io/js/termstyle)

<!-- [![Build Status](https://travis-ci.org/rodw/termstyle.svg?branch=master)](https://travis-ci.org/rodw/termstyle) -->

**[TermStyle](https://github.com/rodw/termstyle)** is a (server-side) JavaScript library that provides utility functions supporting styled console (terminal) output.

TermStyle supports:

1. ANSI-text-color formatting (building on top of [chalk](https://github.com/sindresorhus/chalk))

2. Various methods of left, right and center alignment, padding and filling.

3. Wrapping and truncating text to a predefined and/or the current console width.

4. The declarative defintion of theme-able style "classes".

## Using

(This is an early release of TermStyle, the API may change slightly in future releases.)

### (example)

```coffeescript
# generates a function that applies the given
# prefix to an input string (used below in
# the theme defintion
make_prefix_fn = (p)->
  return ((x)->"#{p}#{x}")

# define a custom theme and a few styles
theme = {
  tab_width: 4
  tabs_as_spaces:true
  styles: {
    banner:  ["inverse","bold","blue","center","stripColor","truncate"]
    BANNER:  ["banner","upper"]
    error:   ["red",   make_prefix_fn(chalk.inverse.bold("[ERROR]")+" ")]
    warning: ["yellow",make_prefix_fn(chalk.inverse.bold("[WARNING]")+" ")]
    note:    ["blue",  make_prefix_fn(chalk.inverse.bold("[NOTE]")+" ")]
  }
}

# create the formatter
f = new Formatter(theme)

# use it
console.log(f.BANNER("Big Bold Banner"))

console.log(f.error("Oops, an error occurred"))

console.log(f.warning("This is a warning"))

console.log(f.note("This is just a note"))

console.log(f.wrap("Imagine this is very long text that needs to be wrapped to fit on-screen.\nMulti-line text is OK.  Each line will be wrapped independently."))
```


## Installing

The source code and documentation for TermStyle is available on GitHub at [rodw/termstyle](https://github.com/rodw/termstyle).  You can clone the repository via:

```console
git clone git@github.com:rodw/termstyle.git
```

<!--
TermStyle is deployed as an [npm module](https://npmjs.org/) under the name [`termstyle`](https://npmjs.org/package/termstyle). Hence you can install a pre-packaged version with the command:

```console
npm install termstyle
```

and you can add it to your project as a dependency by adding a line like:

```javascript
"termstyle": "latest"
```

to the `dependencies` or `devDependencies` part of your `package.json` file.
-->

## Licensing

The TermStyle library and related documentation are made available under an [MIT License](http://opensource.org/licenses/MIT).  For details, please see the file [LICENSE.txt](LICENSE.txt) in the root directory of the repository.
