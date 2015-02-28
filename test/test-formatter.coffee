should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join(__dirname,'..')
LIB_DIR   = if fs.existsSync(path.join(HOMEDIR,'lib-cov')) then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
Formatter = require(path.join(LIB_DIR,'formatter')).Formatter
chalk = require 'chalk'

describe "Formatter",->

  it "can upcase and downcase text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ 'Lorem Ipsum', 'LOREM IPSUM', 'lorem ipsum' ]
      [ '', '', '' ]
      [ null, null, null ]
    ]
    for test in tests
      if test[1]?
        f.upper(test[0]).should.equal test[1]
      else
        should.not.exist f.upper(test[0])
      if test[2]?
        f.lower(test[0]).should.equal test[2]
      else
        should.not.exist f.lower(test[0])
    done()

  it "can left-pad strings",(done)->
    f = new Formatter(pad_left:7)
    tests = [
      [ [0,''],'' ]
      [ [1,''],' ' ]
      [ [2,''],'  ' ]
      [ [3,''],'   ' ]
      [ [1,'x'],' x' ]
      [ [1,'xx'],' xx' ]
      [ [2,'x'],'  x' ]
      [ [3,'x'],'   x' ]
      [ [4,'x'],'    x' ]
      [ [4,'xx'],'    xx' ]
      [ [5,'x'],'     x' ]
      [ [5,'xx'],'     xx' ]
      [ ['x'],'       x']
    ]
    for test in tests
      f.lpad(test[0]...).should.equal test[1]
    done()

  it "can right-pad strings",(done)->
    f = new Formatter(pad_right:7)
    tests = [
      [ [0,''],'' ]
      [ [1,''],' ' ]
      [ [2,''],'  ' ]
      [ [3,''],'   ' ]
      [ [1,'x'],'x ' ]
      [ [1,'xx'],'xx ' ]
      [ [2,'x'],'x  ' ]
      [ [3,'x'],'x   ' ]
      [ [4,'x'],'x    ' ]
      [ [4,'xx'],'xx    ' ]
      [ [5,'x'],'x     ' ]
      [ [5,'xx'],'xx     ' ]
      [ ['x'],'x       ']
    ]
    for test in tests
      f.rpad(test[0]...).should.equal test[1]
    done()

  it "can center-align text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [0,''],'' ]
      [ [1,''],' ' ]
      [ [2,''],'  ' ]
      [ [3,''],'   ' ]
      [ [1,'x'],'x' ]
      [ [1,'xx'],'xx' ]
      [ [2,'x'],'x ' ]
      [ [3,'x'],' x ' ]
      [ [4,'x'],' x  ' ]
      [ [4,'xx'],' xx ' ]
      [ [5,'x'],'  x  ' ]
      [ [5,'xx'],' xx  ' ]
      [ ['x'],'                   x                    ' ]
    ]
    for test in tests
      f.center(test[0]...).should.equal test[1]
    done()

  it "can center-align multi-line text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ ["x\nxx\nxxx\n\nxxxx\nxxxxx"],"                   x                    \n                   xx                   \n                  xxx                   \n                                        \n                  xxxx                  \n                 xxxxx                  "]
    ]
    for test in tests
      # console.log "\n"+test[1]
      # console.log "\n"+f.center(test[0]...)
      f.center(test[0]...).should.equal test[1]
    done()

  it "can left-align text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [0,''],'' ]
      [ [1,''],' ' ]
      [ [2,''],'  ' ]
      [ [3,''],'   ' ]
      [ [1,'x'],'x' ]
      [ [1,'xx'],'xx' ]
      [ [2,'x'],'x ' ]
      [ [3,'x'],'x  ' ]
      [ [4,'x'],'x   ' ]
      [ [4,'xx'],'xx  ' ]
      [ [5,'x'],'x    ' ]
      [ [5,'xx'],'xx   ' ]
      [ ['x'],'x                                       ']
    ]
    for test in tests
      f.left(test[0]...).should.equal test[1]
    done()

  it "can left-align multi-line text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ ["x\nxx\nxxx\n\nxxxx\nxxxxx"],"x                                       \nxx                                      \nxxx                                     \n                                        \nxxxx                                    \nxxxxx                                   "]
    ]
    for test in tests
      f.left(test[0]...).should.equal test[1]
    done()

  it "can right-align text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [0,''],'' ]
      [ [1,''],' ' ]
      [ [2,''],'  ' ]
      [ [3,''],'   ' ]
      [ [1,'x'],'x' ]
      [ [1,'xx'],'xx' ]
      [ [2,'x'],' x' ]
      [ [3,'x'],'  x' ]
      [ [4,'x'],'   x' ]
      [ [4,'xx'],'  xx' ]
      [ [5,'x'],'    x' ]
      [ [5,'xx'],'   xx' ]
      [ ['x'],'                                       x']
    ]
    for test in tests
      f.right(test[0]...).should.equal test[1]
    done()

  it "can right-align multi-line text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ ["x\nxx\nxxx\n\nxxxx\nxxxxx"],"                                       x\n                                      xx\n                                     xxx\n                                        \n                                    xxxx\n                                   xxxxx"]
    ]
    for test in tests
      f.right(test[0]...).should.equal test[1]
    done()

  it "can truncate text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [0,''],'' ]
      [ [1,''],'' ]
      [ [2,''],'' ]
      [ [3,''],'' ]
      [ [1,'123456789'],"#{chalk.gray("…")}" ]
      [ [2,'123456789'],"1#{chalk.gray("…")}" ]
      [ [3,'123456789'],"12#{chalk.gray("…")}" ]
      [ [5,'123456789'],"1234#{chalk.gray("…")}" ]
    ]
    for test in tests
      # console.log JSON.stringify(test)
      f.truncate(test[0]...).should.equal test[1]
    done()

  it "can truncate multi-line text",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [5,'123456789\n123456789\n\n12345\n123456\n1234'],"1234#{chalk.gray("…")}\n1234#{chalk.gray("…")}\n\n12345\n1234#{chalk.gray("…")}\n1234" ]
    ]
    for test in tests
      f.truncate(test[0]...).should.equal test[1]
    done()
