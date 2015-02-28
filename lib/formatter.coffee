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
    @combine_multiple_space_chars = @theme.combine_multiple_space_chars ? DEFAULT_THEME.combine_multiple_space_chars ? true
    @tabs_as_spaces = @theme.tabs_as_spaces ? DEFAULT_THEME.tabs_as_spaces ? false
    @_add_styles(@theme.styles ? DEFAULT_THEME.styles)
    @_add_chalk_functions()
    @_on_resize()

  track_resize:()=>
    process.stdout.on('resize',@_on_resize)

  # wrap long lines
  wrap:(text,options)=>
    width = options?.width ? @_get_width() ? 80
    tab_width = options?.tab_width ? @tab_width ? 4
    tabs_as_spaces = options?.tabs_as_spaces ? @tabs_as_spaces ? false
    indent = options?.indent ? @indent ? 0
    if typeof indent is 'number'
      indent = @ntimes(indent," ")
    indent_len = chalk.stripColor(indent).length
    if /^\t+$/.test indent
      indent_len = 8*tab_width
    if indent_len > width
      throw new Error("Indent length cannot be greater than width. Found indent \""+indent+"\" ("+ indent_len + "), width " + width + ".")
    pad_left = options?.pad_left ? @pad_left ? 0
    pad_left_str = @ntimes(pad_left,' ')
    pad_right = options?.pad_left ? @pad_right ? 0
    pad_right_str = @ntimes(pad_right,' ')
    pad_len = pad_left + pad_right
    if pad_len > width
      throw new Error("Pad length cannot be greater than width. Found "+pad_len+" > "+width+".")
    combine_multiple_space_chars = options?.combine_multiple_space_chars ? @combine_multiple_space_chars ? true
    target_width = width - pad_len
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
          else if /^\s+$/.test word
            if combine_multiple_space_chars
              word = " "
              len = 1
          if (cur_line_len + len) > target_width
            if /\S/.test cur_line
              if indent_needed
                buffer.push indent
                indent_needed = false
              buffer.push pad_left_str + cur_line.trim()
              buffer.push "\n"
            if len > target_width
              buffer.push pad_left_str + word
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
          buffer.push pad_left_str + cur_line.trim()
          cur_line = ""
          cur_line_line = 0
    str = buffer.join('')
    if tabs_as_spaces
      str = str.replace(/\t/mg,@ntimes(tab_width,' '))
    return buffer.join('')

  # convert the given string to upper case
  upper:(str)=>str?.toUpperCase()

  # convert the given string to lower case
  lower:(str)=>str?.toLowerCase()

  # add `padding` characters to the left of `str`
  lpad:(padding,str)=>
    [padding,str] = @_nsb(padding,str)
    padding = padding ? @pad_left
    if padding? and padding > 0
      return @ntimes(padding,' ')+str
    else
      return str

  # add `padding` characters to the right of `str`
  rpad:(padding,str)=>
    [padding,str] = @_nsb(padding,str)
    padding = padding ? @pad_right
    if padding? and padding > 0
      return str + @ntimes(padding,' ')
    else
      return str


  # truncate (each line of) the given `text` to `width` characters
  truncate:(width,text)=>
    [width,text] = @_nsb(width,text)
    buffer = []
    lines = text.match /[\n\r\f\v]|([^\n\r\f\v]+)/mg
    if lines?
      for line in lines
        if /^[\n\r\f\v]+$/.test line
          buffer.push line
        else
          buffer.push @_truncate(width,line)
    return buffer.join('')


  # truncate the given `str` to `width` characters
  _truncate:(width,str)=>
    [width,str] = @_nsb(width,str)
    len = chalk.stripColor(str).length
    if len > width
      el = chalk.stripColor(@ellipses).length
      if el > width
        throw new Error("Width cannot be less than length of ellipses")
      return str.substring(0,width-el)+@ellipses
    else
      return str

  # repeat the given string n times
  ntimes:(n,str)=>
    [n,str] = @_nsb(n,str)
    buf = ""
    for i in [0...n]
      buf += str
    return buf

  # repeat the given string as many times as possible to fill `w` (partial lines if necessary)
  fill:(width,str)=>
    [width,str] = @_nsb(width,str)
    len = chalk.stripColor(str).length
    n = Math.floor(width/len)
    buf = @ntimes(n,str)
    if (n*len) < width
      buf += x.substring(0,width-(n*len)) # TODO should pay attention to color here
    return buf

  # right align (each line of) the given `text` to lines `width` characters long.
  right:(width,text,pad=false)=>
    [width,text,pad] = @_nsb(width,text,pad)
    if width is 0
      return text
    else if text is ''
      return @ntimes(width,' ')
    else
      buffer = []
      lines = text.match /[\n\r\f\v]|([^\n\r\f\v]+)/mg
      last_was_newline = true
      for line in lines
        if /^[\n\r\f\v]+$/.test line
          if last_was_newline
            buffer.push (@_right(width,'',pad)+line)
          else
            buffer.push line
            last_was_newline = true
        else
          buffer.push @_right(width,line,pad)
          last_was_newline = false
      return buffer.join('')

  # right align the given text to `w` characters
  _right:(width,str,pad=false)=>
    [width,str,pad] = @_nsb(width,str,pad)
    unless width?
      width = @_get_width()
    if pad
      str = @rpad(str)
    len = chalk.stripColor(str).length
    buf = ""
    if len < width
      buf += @ntimes(width-len,' ')
    buf += str
    return buf

  left:(width,text,pad=false)=>
    [width,text,pad] = @_nsb(width,text,pad)
    if width is 0
      return text
    else if text is ''
      return @ntimes(width,' ')
    else
      buffer = []
      lines = text.match /[\n\r\f\v]|([^\n\r\f\v]+)/mg
      last_was_newline = true
      for line in lines
        if /^[\n\r\f\v]+$/.test line
          if last_was_newline
            buffer.push (@_right(width,'',pad)+line)
          else
            buffer.push line
            last_was_newline = true
        else
          buffer.push @_left(width,line,pad)
          last_was_newline = false
      return buffer.join('')

  # left align the given `str` to `width` characters
  _left:(width,str,pad=false)=>
    [width,str,pad] = @_nsb(width,str,pad)
    unless width?
      width = @_get_width()
    if pad
      str = @lpad(str)
    len = chalk.stripColor(str).length
    buf = str
    if len < width
      buf += @ntimes(width-len,' ')
    return buf

  center:(width,text)=>
    [width,text] = @_nsb(width,text)
    if width is 0
      return text
    else if text is ''
      return @ntimes(width,' ')
    else
      buffer = []
      lines = text.match /[\n\r\f\v]|[^\n\r\f\v]+/mg
      last_was_newline = true
      for line in lines
        if /^[\n\r\f\v]+$/.test line
          if last_was_newline
            buffer.push @_right(width,'',false)+line
          else
            buffer.push line
            last_was_newline = true
        else
          buffer.push @_center(width,line)
          last_was_newline = false
      return buffer.join('')

  # center align the given `str` to `width` characters
  _center:(width,str)=>
    [width,str] = @_nsb(width,str)
    unless width?
      width = @_get_width()
    len = chalk.stripColor(str).length
    if len < width
      pre = Math.floor((width-len)/2)
      post = width-(len+pre)
      return  @ntimes(pre,' ') + str + @ntimes(post,' ')
    else
      return str

  # return the first number, string and boolean found in `args` as `[n,s,b]`
  _nsb:(args...)=>
    n = null
    s = null
    b = null
    for arg in args
      if typeof arg is 'number'
        unless n?
          n = arg
      else if typeof arg is 'string'
        unless s?
          s = arg
      else if typeof arg is 'boolean'
        unless b?
          b = arg
      if n? and s? and b?
        return [n,s,b]
    return [n,s,b]

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

  # _wx:(w,x)=>
  #   if not x? and typeof w is 'string'
  #     x = w
  #     w = null
  #   w = @_get_width(w)
  #   return [w,x]

f = new Formatter()

exports.Formatter = Formatter

# # text = "When using the RegExp constructor: for each backslash in your regular expression, you have to type \\ in the RegExp constructor. (In JavaScript strings, \\ represents a single backslash!) For example, the following regular expressions match all leading and trailing whitespaces (\s); note that \\s is passed as part of the first argument of the RegExp constructor"
# text = """
# To scan the lines of his face, or feel the bumps on the head of this Leviathan; this is a thing which no Physiognomist or Phrenologist has as yet undertaken. Such an enterprise would seem almost as hopeful as for Lavater to have scrutinized the wrinkles on the Rock of Gibraltar, or for Gall to have mounted a ladder and manipulated the Dome of the Pantheon. Still, in that famous work of his, Lavater not only treats of the various faces of men, but also attentively studies the faces of horses, birds, serpents, and fish; and dwells in detail upon the modifications of expression discernible therein. Nor have Gall and his disciple Spurzheim failed to throw out some hints touching the phrenological characteristics of other beings than man. Therefore, though I am but ill qualified for a pioneer, in the application of these two semi-sciences to the whale, I will do my endeavor. I try all things; I achieve what I can.

# Physiognomically regarded, the Sperm Whale is an anomalous creature. He has no proper nose. And since the nose is the central and most conspicuous of the features; and since it perhaps most modifies and finally controls their combined expression; hence it would seem that its entire absence, as an external appendage, must very largely affect the countenance of the whale. For as in landscape gardening, a spire, cupola, monument, or tower of some sort, is deemed almost indispensable to the completion of the scene; so no face can be physiognomically in keeping without the elevated open-work belfry of the nose. Dash the nose from Phidias's marble Jove, and what a sorry remainder! Nevertheless, Leviathan is of so mighty a magnitude, all his proportions are so stately, that the same deficiency which in the sculptured Jove were hideous, in him is no blemish at all. Nay, it is an added grandeur. A nose to the whale would have been impertinent. As on your physiognomical voyage you sail round his vast head in your jolly-boat, your noble conceptions of him are never insulted by the reflection that he has a nose to be pulled. A pestilent conceit, which so often will insist upon obtruding even when beholding the mightiest royal beadle on his throne.

# In some particulars, perhaps the most imposing physiognomical view to be had of the Sperm Whale, is that of the full front of his head. This aspect is sublime.
# """

# console.log(f.warning("Lorem Ipsum"))
# console.log(f.hr('='))
# console.log f.underline(f.left(null,f.wrap(text),false))
# console.log(f.hr('='))
# console.log f.underline((f.wrap(text)))
# console.log(f.HR())
# console.log f.truncate(text)
# console.log(f.HR())
# console.log(f.ts("Time stamped"))
# console.log(f.center(null,"Center",true))
# console.log(f.right(null,"Right",true))
# console.log(f.bgRed(f.left("Left",true)))
# console.log "BANNER"
# console.log(f.BANNER(text))
# console.log(f.BANNER("Lorem Ipsum"))
# console.log "banner"
# console.log(f.banner("Lorem Ipsum"))
# console.log(f.hr('.'))
# console.log "TITLE"
# console.log(f.TITLE("Lorem Ipsum"))
# console.log "title"
# console.log(f.title("Lorem Ipsum"))
# console.log(f.hr('.'))
# console.log(f.hr('.'))
# console.log(f.error("Lorem Ipsum"))
# console.log(f.hr('~'))
# console.log(f.note("Lorem Ipsum"))
