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

  it "can fill lines",(done)->
    f = new Formatter(fixed_width:40)
    tests = [
      [ [5,' '],"     " ]
      [ [5],"     " ]
      [ [5,'.'],"....." ]
      [ [5,'.='],".=.=." ]
      [ [6,'.='],".=.=.=" ]
      [ [3,'12345'],"123" ]
    ]
    for test in tests
      f.fill(test[0]...).should.equal test[1]
    done()

  it "can wrap text",(done)->
    f = new Formatter()
    tests = [
      [ [MOBY_DICK,width:60],MOBY_DICK_WRAP_60 ]
    ]
    for test in tests
      f.wrap(test[0]...).should.equal test[1]
    done()


MOBY_DICK = """
Call me Ishmael. Some years ago—never mind how long precisely—having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people's hats off—then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.

There now is your insular city of the Manhattoes, belted round by wharves as Indian isles by coral reefs—commerce surrounds it with her surf. Right and left, the streets take you waterward. Its extreme downtown is the battery, where that noble mole is washed by waves, and cooled by breezes, which a few hours previous were out of sight of land. Look at the crowds of water-gazers there.

Circumambulate the city of a dreamy Sabbath afternoon. Go from Corlears Hook to Coenties Slip, and from thence, by Whitehall, northward. What do you see?—Posted like silent sentinels all around the town, stand thousands upon thousands of mortal men fixed in ocean reveries. Some leaning against the spiles; some seated upon the pier-heads; some looking over the bulwarks of ships from China; some high aloft in the rigging, as if striving to get a still better seaward peep. But these are all landsmen; of week days pent up in lath and plaster—tied to counters, nailed to benches, clinched to desks. How then is this? Are the green fields gone? What do they here?

But look! here come more crowds, pacing straight for the water, and seemingly bound for a dive. Strange! Nothing will content them but the extremest limit of the land; loitering under the shady lee of yonder warehouses will not suffice. No. They must get just as nigh the water as they possibly can without falling in. And there they stand—miles of them—leagues. Inlanders all, they come from lanes and alleys, streets and avenues—north, east, south, and west. Yet here they all unite. Tell me, does the magnetic virtue of the needles of the compasses of all those ships attract them thither?

Once more. Say you are in the country; in some high land of lakes. Take almost any path you please, and ten to one it carries you down in a dale, and leaves you there by a pool in the stream. There is magic in it. Let the most absent-minded of men be plunged in his deepest reveries—stand that man on his legs, set his feet a-going, and he will infallibly lead you to water, if water there be in all that region. Should you ever be athirst in the great American desert, try this experiment, if your caravan happen to be supplied with a metaphysical professor. Yes, as every one knows, meditation and water are wedded for ever.
"""
MOBY_DICK_WRAP_60 = "" +
  " Call me Ishmael. Some years ago—never mind how long\n"+
  " precisely—having little or no money in my purse, and\n"+
  " nothing particular to interest me on shore, I thought I\n"+
  " would sail about a little and see the watery part of the\n"+
  " world. It is a way I have of driving off the spleen and\n"+
  " regulating the circulation. Whenever I find myself growing\n"+
  " grim about the mouth; whenever it is a damp, drizzly\n"+
  " November in my soul; whenever I find myself involuntarily\n"+
  " pausing before coffin warehouses, and bringing up the rear\n"+
  " of every funeral I meet; and especially whenever my hypos\n"+
  " get such an upper hand of me, that it requires a strong\n"+
  " moral principle to prevent me from deliberately stepping\n"+
  " into the street, and methodically knocking people's hats\n"+
  " off—then, I account it high time to get to sea as soon as\n"+
  " I can. This is my substitute for pistol and ball. With a\n"+
  " philosophical flourish Cato throws himself upon his sword;\n"+
  " I quietly take to the ship. There is nothing surprising\n"+
  " in this. If they but knew it, almost all men in their\n"+
  " degree, some time or other, cherish very nearly the same\n"+
  " feelings towards the ocean with me.\n"+
  "\n" +
  " There now is your insular city of the Manhattoes, belted\n"+
  " round by wharves as Indian isles by coral reefs—commerce\n"+
  " surrounds it with her surf. Right and left, the streets\n"+
  " take you waterward. Its extreme downtown is the battery,\n"+
  " where that noble mole is washed by waves, and cooled by\n"+
  " breezes, which a few hours previous were out of sight of\n"+
  " land. Look at the crowds of water-gazers there.\n"+
  "\n" +
  " Circumambulate the city of a dreamy Sabbath afternoon. Go\n"+
  " from Corlears Hook to Coenties Slip, and from thence, by\n"+
  " Whitehall, northward. What do you see?—Posted like silent\n"+
  " sentinels all around the town, stand thousands upon\n"+
  " thousands of mortal men fixed in ocean reveries. Some\n"+
  " leaning against the spiles; some seated upon the\n"+
  " pier-heads; some looking over the bulwarks of ships from\n"+
  " China; some high aloft in the rigging, as if striving to\n"+
  " get a still better seaward peep. But these are all\n"+
  " landsmen; of week days pent up in lath and plaster—tied to\n"+
  " counters, nailed to benches, clinched to desks. How then\n"+
  " is this? Are the green fields gone? What do they here?\n"+
  "\n" +
  " But look! here come more crowds, pacing straight for the\n"+
  " water, and seemingly bound for a dive. Strange! Nothing\n"+
  " will content them but the extremest limit of the land;\n"+
  " loitering under the shady lee of yonder warehouses will\n"+
  " not suffice. No. They must get just as nigh the water as\n"+
  " they possibly can without falling in. And there they\n"+
  " stand—miles of them—leagues. Inlanders all, they come from\n"+
  " lanes and alleys, streets and avenues—north, east, south,\n"+
  " and west. Yet here they all unite. Tell me, does the\n"+
  " magnetic virtue of the needles of the compasses of all\n"+
  " those ships attract them thither?\n"+
  "\n" +
  " Once more. Say you are in the country; in some high land\n"+
  " of lakes. Take almost any path you please, and ten to one\n"+
  " it carries you down in a dale, and leaves you there by a\n"+
  " pool in the stream. There is magic in it. Let the most\n"+
  " absent-minded of men be plunged in his deepest\n"+
  " reveries—stand that man on his legs, set his feet a-going,\n"+
  " and he will infallibly lead you to water, if water there\n"+
  " be in all that region. Should you ever be athirst in the\n"+
  " great American desert, try this experiment, if your\n"+
  " caravan happen to be supplied with a metaphysical\n"+
  " professor. Yes, as every one knows, meditation and water\n"+
  " are wedded for ever."
