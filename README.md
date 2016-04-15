# TermStyle [![Dependencies](https://david-dm.org/rodw/termstyle.svg)](https://npmjs.org/package/termstyle) [![NPM version](https://badge.fury.io/js/termstyle.svg)](http://badge.fury.io/js/termstyle)

<!-- [![Build Status](https://travis-ci.org/rodw/termstyle.svg?branch=master)](https://travis-ci.org/rodw/termstyle) -->

**[TermStyle](https://github.com/rodw/termstyle)** is a (server-side) JavaScript library that provides utility functions supporting styled console (terminal) output.

Using TermStyle you can achieve effects like the following (which was directly generated from the sample code shown below).

![](https://raw.githubusercontent.com/rodw/termstyle/master/screenshot.png)

TermStyle supports:

1. ANSI-text-color formatting (building on top of [chalk](https://github.com/sindresorhus/chalk))

2. Various methods of left, right and center alignment, padding and filling.

3. Wrapping and truncating text to a predefined and/or the current console width.

4. The declarative definition of theme-able style "classes".

## Using

(This is an early release of TermStyle, the API may change slightly in future releases.)

### (example)

```coffeescript
# 'Formatter' is the primary utility used in termstyle.
Formatter = require('./lib/formatter').Formatter
f = new Formatter()

console.log "\n"

# You can apply styles to any string:
console.log(f.TITLE("Welcome to TermStyle."))

# But since this is CoffeeScript, we can skip the parens to make it a little cleaner:
console.log f.magenta "Easy-peasey colors."

# There are a lot of different styles available:
console.log f.center "Centered text."
console.log f.underline "Underlined text."
console.log f.right "Right-aligned."
console.log f.italic "Italic text."
console.log f.black f.bgYellow "Background and foreground."
console.log f.error "Reporting an error."
# You can also combine styles:
console.log f.error "Reporting an error " + f.italic "that contains italic text."
# And as we'll see below, you can add your own.

console.log "\n"

# You can define a custom theme that over overrides a few configuration parameters.
theme = {
  max_width:45
  ellipses:"..."
  tab_width: 4
  tabs_as_spaces:true
}
f = new Formatter(theme)
console.log f.title "Now my title is narrower."

console.log f.wrap "\n...which is a good chance to show off the automatic wrapping function.  When we have long text like this we can automatically wrap it to the size of the terminal.\n" +
                    "\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n" +
                    "\nMulti-line text is OK.  Each line will be wrapped independently."

# You can also define "declarative" styles that will
# add simple functions to your Formatter that you can
# use to apply the style.
theme = {}
theme.styles = {}

# Styles are defined declaratively, for instance, here
# a style that will create a "banner" (as seen in the
# screenshot)
theme.styles.banner = ["inverse","bold","red","center","stripColor","truncate"]

# You can use one declarative style in the definition of another:
theme.styles.BANNER = ["banner","upper"]

# Your style parameters can also be functions that transform the
# input text in any way that you want.

# For example this function will prefix the word `ERROR` in
# bold letters before any input string:
prefix_error = (str)=>f.bold("[ERROR] ") + str
# Here's a couple more:
prefix_warning = (str)=>f.bold("[WARNING] ") + str
prefix_note = (str)=>f.bold("[NOTE] ") + str

# Let's use those functions to create some new styles:
theme.styles.error      = [ "red", prefix_error ]
theme.styles.warning    = [ "yellow", prefix_warning ]
theme.styles.note       = [ "blue", prefix_note ]
theme.styles.right_note = [ "right", "blue", prefix_note ]

# Now let's try those new styles:

f = new Formatter(theme)
console.log f.BANNER "Big Red Banner"
console.log f.warning "This is a warning"
console.log f.error "Oops, an error occurred"
console.log f.note "This is just a note"
console.log f.right_note "A note on the right."

console.log "\n"
```


## Installing

The source code and documentation for TermStyle is available on GitHub at [rodw/termstyle](https://github.com/rodw/termstyle).  You can clone the repository via:

```console
git clone git@github.com:rodw/termstyle.git
```

TermStyle is deployed as an [npm module](https://npmjs.org/) under the name [`termstyle`](https://npmjs.org/package/termstyle). Hence you can install a pre-packaged version with the command:

```console
npm install termstyle
```

and you can add it to your project as a dependency by adding a line like:

```javascript
"termstyle": "latest"
```

to the `dependencies` or `devDependencies` part of your `package.json` file.

## Licensing

The TermStyle library and related documentation are made available under an [MIT License](http://opensource.org/licenses/MIT).  For details, please see the file [LICENSE.txt](LICENSE.txt) in the root directory of the repository.
