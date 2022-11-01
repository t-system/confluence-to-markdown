Bootstrap = require './Bootstrap'

pathResource = process.argv[2] # can also be a file
pathResult = process.argv[3]
runScript = if (!process.argv[4] || process.argv[4] == 'false') then false else true
verboseLogs = if (!process.argv[5] || process.argv[5] == 'false') then false else true

bootstrap = new Bootstrap
bootstrap.run pathResource, pathResult, runScript, verboseLogs
