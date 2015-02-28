should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join(__dirname,'..')
LIB_DIR   = if fs.existsSync(path.join(HOMEDIR,'lib-cov')) then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
Formatter = require(path.join(LIB_DIR,'formatter')).Formatter

describe "Formatters",->

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
