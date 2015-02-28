chalk = require 'chalk'

CHALK_FUNCTIONS = [
  'stripColor'
  'reset'
  'bold'
  'dim'
  'italic'
  'underline'
  'inverse'
  'strikethrough'
  'black'
  'red'
  'green'
  'yellow'
  'blue'
  'magenta'
  'cyan'
  'white'
  'gray'
  'bgBlack'
  'bgRed'
  'bgGreen'
  'bgYellow'
  'bgBlue'
  'bgMagenta'
  'bgCyan'
  'bgWhite'
]

mcf = (c)->((x)->x ? c)
mpf = (p)->((x)->"#{p}#{x}")
tsf = ()->((x)->chalk.gray("[#{new Date().toISOString()}]") + " " + x)
DEFAULT_THEME = {
  max_width: 120
  ellipses: chalk.gray("…")
  tab_width: 20
  fixed_width: null
  pad_left: 1
  pad_right: 1
  styles: {
    BANNER: ["banner","upper"]
    banner: ["inverse","bold","blue","center","stripColor","truncate"]
    TITLE: ["title","upper"]
    title: ["underline","bold","blue","center","stripColor","truncate"]
    hr: ["gray","fill",mcf('-')]
    HR: ["inverse","gray","fill",mcf(' ')]
    error:   [tsf(), "red",   mpf(chalk.inverse.bold("[ERR]")+" ")]
    warning: [tsf(), "yellow",mpf(chalk.inverse.bold("[WAR]")+" ")]
    note:    [tsf(), "blue",  mpf(chalk.inverse.bold("[NOT]")+" ")]
    ts: [tsf()]
  }
}

class Formatter
  current_width: null
  current_height: null

  constructor:(@theme = DEFAULT_THEME)->
    @max_width = @theme.max_width ? DEFAULT_THEME.max_width ? 120
    @tab_width = @theme.tab_width ? DEFAULT_THEME.tab_width ? 4
    @indent = @theme.indent ? DEFAULT_THEME.indent ? 0
    @fixed_width = @theme.fixed_width ? DEFAULT_THEME.fixed_width ? null
    @pad_left = @theme.pad_left ? DEFAULT_THEME.pad_left ? 1
    @pad_right = @theme.pad_right ? DEFAULT_THEME.pad_right ? 1
    @ellipses = @theme.ellipses ? DEFAULT_THEME.ellipses ? "..."
    @_add_styles(@theme.styles)
    process.stdout.on('resize',@_on_resize)
    @_add_chalk_functions()
    @_on_resize()

  # wrap long lines to `options.width` characters
  wrap:(text,options)=>
    width = options?.width ? @_get_width() ? 80
    tab_width = options?.tab_width ? @tab_width
    indent = options?.indent ? @indent
    if typeof indent is 'number'
      indent = @ntimes(indent," ")
    indent_len = chalk.stripColor(indent).length
    if /^\t+$/.test indent
      indent_len = 8*tab_width
    if indent_len > width
      throw new Error("Indent length cannot be greater than width. Found indent \""+indent+"\" ("+ indent_len + "), width " + width + ".")
    ##########
    buffer = []
    lines = text.match /[\n\r\f\v]+|[^\n\r\f\v]+/mg
    for line,i in lines
      if /^[\n\r\f\v]+$/mg.test line
        buffer.push line
      else
        indent_needed = true
        cur_line = ""
        cur_line_len = indent_len
        words = line.match /\t+|\s+|[^\s]+/mg
        for word in words
          len = chalk.stripColor(word).length
          if /^\t+$/.test word
            len = len*tab_width
          if (cur_line_len + len) > width
            if /\S/.test cur_line
              if indent_needed
                buffer.push indent
                indent_needed = false
              buffer.push cur_line.trim()
              buffer.push "\n"
            if len > width
              buffer.push word
              buffer.push "\n"
              cur_line = ""
              cur_line_len = 0
            else
              cur_line = word
              cur_line_len = len
          else
            cur_line += word
            cur_line_len += len
        if cur_line_len > 0
          buffer.push cur_line.trim()
          cur_line = ""
          cur_line_line = 0
    return buffer.join('')

  upper:(x)=>x.toUpperCase()

  lower:(x)=>x.toLowerCase()

  # padding the given string with padding characters on the left
  lpad:(x,padding)=>
    padding = padding ? @pad_left
    if padding? and padding > 0
      return @ntimes(padding,' ')+x
    else
      return x

  # padding the given string with padding characters on the right
  rpad:(x,padding)=>
    padding = padding ? @pad_right
    if padding? and padding > 0
      return x + @ntimes(padding,' ')
    else
      return x

  truncate:(w,x)=>
    [w,x] = @_wx(w,x)
    l = chalk.stripColor(x).length
    if l > w
      el = chalk.stripColor(@ellipses).length
      str = x.substring(0,w-el)+@ellipses
    else
      return x


  # repeat the given string n times
  ntimes:(n,x)=>
    buf = ""
    for i in [0...n]
      buf += x
    return buf

  # repeat the given string as many times as possible to fill `w` (partial lines if necessary)
  fill:(w,x)=>
    [w,x] = @_wx(w,x)
    l = chalk.stripColor(x).length
    n = Math.floor(w/l)
    buf = @ntimes(n,x)
    if (n*l) < w
      buf += x.substring(0,w-(n*l)) # TODO should pay attention to color here
    return buf

  # right align the given text to `w` characters
  right:(w,x)=>
    [w,x] = @_wx(w,x)
    x = @rpad(x)
    l = chalk.stripColor(x).length
    buf = ""
    if l < w
      buf += @ntimes(w-l,' ')
    buf += x
    return buf

  # left align the given text to `w` characters (with padding)
  left:(w,x)=>
    [w,x] = @_wx(w,x)
    x = @lpad(x)
    l = chalk.stripColor(x).length
    buf = x
    if l < w
      buf += @ntimes(w-l,' ')
    return buf

  # center align the given text to `w` characters (with padding)
  center:(w,x)=>
    [w,x] = @_wx(w,x)
    l = chalk.stripColor(x).length
    if l < w
      pre = Math.floor((w-l)/2)
      post = w-l-pre
      return  @ntimes(pre,' ') + x + @ntimes(post,' ')
    else
      return x

  _add_styles:(sty=STYLES)=>
    msf = (style)=> (x)=>@_apply(style,x)
    for name, style of sty
      this[name] = msf(style)

  _add_chalk_functions:(fn=CHALK_FUNCTIONS)=>
    for f in fn
      this[f] = chalk[f]

  # apply list of functions, i.e, `y = f0(f1(f2(...(fn(x))...)))`
  _apply:(fns,x)=>
    for i in [(fns.length-1)..0]
      f = fns[i]
      if typeof f is 'string'
        f = this[f]
      x = f(x)
    return x

  _get_width:(w)=>w ? @fixed_width ? Math.min(@current_width,@max_width)

  _on_resize:()=>
    @current_width = process.stdout.columns
    @current_height = process.stdout.rows

  _wx:(w,x)=>
    if not x? and typeof w is 'string'
      x = w
      w = null
    w = @_get_width(w)
    return [w,x]

f = new Formatter()

# text = "When using the RegExp constructor: for each backslash in your regular expression, you have to type \\ in the RegExp constructor. (In JavaScript strings, \\ represents a single backslash!) For example, the following regular expressions match all leading and trailing whitespaces (\s); note that \\s is passed as part of the first argument of the RegExp constructor"
text = """
To scan the lines of his face, or feel the bumps on the head of this Leviathan; this is a thing which no Physiognomist or Phrenologist has as yet undertaken. Such an enterprise would seem almost as hopeful as for Lavater to have scrutinized the wrinkles on the Rock of Gibraltar, or for Gall to have mounted a ladder and manipulated the Dome of the Pantheon. Still, in that famous work of his, Lavater not only treats of the various faces of men, but also attentively studies the faces of horses, birds, serpents, and fish; and dwells in detail upon the modifications of expression discernible therein. Nor have Gall and his disciple Spurzheim failed to throw out some hints touching the phrenological characteristics of other beings than man. Therefore, though I am but ill qualified for a pioneer, in the application of these two semi-sciences to the whale, I will do my endeavor. I try all things; I achieve what I can.

Physiognomically regarded, the Sperm Whale is an anomalous creature. He has no proper nose. And since the nose is the central and most conspicuous of the features; and since it perhaps most modifies and finally controls their combined expression; hence it would seem that its entire absence, as an external appendage, must very largely affect the countenance of the whale. For as in landscape gardening, a spire, cupola, monument, or tower of some sort, is deemed almost indispensable to the completion of the scene; so no face can be physiognomically in keeping without the elevated open-work belfry of the nose. Dash the nose from Phidias's marble Jove, and what a sorry remainder! Nevertheless, Leviathan is of so mighty a magnitude, all his proportions are so stately, that the same deficiency which in the sculptured Jove were hideous, in him is no blemish at all. Nay, it is an added grandeur. A nose to the whale would have been impertinent. As on your physiognomical voyage you sail round his vast head in your jolly-boat, your noble conceptions of him are never insulted by the reflection that he has a nose to be pulled. A pestilent conceit, which so often will insist upon obtruding even when beholding the mightiest royal beadle on his throne.

In some particulars, perhaps the most imposing physiognomical view to be had of the Sperm Whale, is that of the full front of his head. This aspect is sublime.
"""

console.log(f.warning("Lorem Ipsum"))
console.log(f.hr('='))
console.log f.wrap(text)
console.log(f.HR())
console.log f.truncate(text)
console.log(f.HR())
console.log(f.ts("Time stamped"))
console.log(f.center("Center"))
console.log(f.hr('='))
console.log "BANNER"
console.log(f.BANNER(text))
console.log(f.BANNER("Lorem Ipsum"))
console.log "banner"
console.log(f.banner("Lorem Ipsum"))
console.log(f.hr('.'))
console.log "TITLE"
console.log(f.TITLE("Lorem Ipsum"))
console.log "title"
console.log(f.title("Lorem Ipsum"))
console.log(f.hr('.'))
console.log(f.hr('.'))
console.log(f.error("Lorem Ipsum"))
console.log(f.hr('~'))
console.log(f.note("Lorem Ipsum"))
