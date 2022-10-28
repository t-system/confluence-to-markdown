Bootstrap = require './Bootstrap'

pathResource = process.argv[2] # can also be a file
pathResult = process.argv[3]
runScript = process.argv[4]

bootstrap = new Bootstrap
bootstrap.run pathResource, pathResult, runScript
