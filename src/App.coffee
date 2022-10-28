class App

  # @link http://hackage.haskell.org/package/pandoc For options description
  @outputTypesAdd = [
    'markdown_github' # use GitHub markdown variant
    'blank_before_header' # insert blank line before header
#    'mmd_link_attributes' # use MD syntax for images and links instead of HTML
#    'link_attributes' # use MD syntax for images and links instead of HTML
  ]

  @outputTypesRemove = [
  ]

  @extraOptions = [
    '--markdown-headings=atx' # Setext-style headers (underlined) | ATX-style headers (prefixed with hashes)
  ]

  ###*
  # @param {fs} _fs Required lib
  # @param {sync-exec} _exec Required lib
  # @param {path} _path Required lib
  # @param {mkdirp} _mkdirp Required lib
  # @param {Utils} utils My lib
  # @param {Formatter} formatter My lib
  # @param {PageFactory} pageFactory My lib
  # @param {Logger} logger My lib
  ###
  constructor: (@_fs, @_exec, @_path, @_mkdirp, @utils, @formatter, @pageFactory, @logger, @_turndownService, @_turndownPluginGfm, @_confluenceTurndownPluginGfm) ->
    typesAdd = App.outputTypesAdd.join '+'
    typesRemove = App.outputTypesRemove.join '-'
    typesRemove = if typesRemove then '-' + typesRemove else ''
    types = typesAdd + typesRemove
    @pandocOptions = [
      if types then '-t ' + types else ''
      App.extraOptions.join ' '
    ].join ' '


  ###*
  # Converts HTML files to MD files.
  # @param {string} dirIn Directory to go through
  # @param {string} dirOut Directory where to place converted MD files
  ###
  convert: (dirIn, dirOut, runScript) ->
    filePaths = @utils.readDirRecursive dirIn
    pages = (@pageFactory.create filePath for filePath in filePaths when filePath.endsWith '.html')

    indexHtmlFiles = []
    rootSpace = ''
    for page in pages
      do (page) =>
        if page.fileName == 'index.html'
          rootSpace = page.space
          indexHtmlFiles.push @_path.join page.space, 'index' # gitit requires link to pages without .md extension
        @convertPage page, dirIn, dirOut

    @writeGlobalIndexFile indexHtmlFiles, dirOut if not @utils.isFile dirIn
    
    @logger.info 'Markdown conversion done!'

    if runScript != false
      @logger.info '\nRunning cleanup scripts...\n'

      linkScriptCmd = 'bash ./src/update-links.sh ' + dirOut + ' ' + rootSpace
      out = @_exec linkScriptCmd
      @logger.info out.stdout
      @logger.error out.stderr if out.status > 0
      @logger.info 'Cleanup scripts done!\n'


  ###*
  # Converts HTML file at given path to MD.
  # @param {Page} page Page entity of HTML file
  # @param {string} dirOut Directory where to place converted MD files
  ###
  convertPage: (page, dirIn, dirOut) ->
    try
      @logger.info 'Parsing ' + page.path

      text = page.getTextToConvert()
      localDir = page.getLocalDir()
      fullOutFileName = @_path.join dirOut, page.space, localDir, page.fileNameNew

      @logger.info 'Making Markdown ' + fullOutFileName
      @writeMarkdownFile text, fullOutFileName, page.confluenceId
      @utils.copyAssets @utils.getDirname(page.path), @utils.getDirname(fullOutFileName)
      @logger.info 'Done\n'
    catch e
      @logger.error 'ERROR: Page conversion for ' + page.path + ' failed - ' + e



  ###*
  # @param {string} text Makdown content of file
  # @param {string} fullOutFileName Absolute path to resulting file
  # @return {string} Absolute path to created MD file
  ###
  writeMarkdownFile: (text, fullOutFileName, confluenceId) ->
    fullOutDirName = @utils.getDirname fullOutFileName

    @_mkdirp.sync fullOutDirName, (error) ->
      if error
        @logger.error 'Unable to create directory #{fullOutDirName}'


    turndownService = new @_turndownService()
    turndownService.use(@_turndownPluginGfm.gfm)
    turndownService.use(@_confluenceTurndownPluginGfm.confluenceGfm)


    metadataPrefix = ["---",
      "confluence-id: #{confluenceId || ''}",
      "confluence-space: %%CONFLUENCE-SPACE%%",
      "---"]
    metadataPrefix = metadataPrefix.map (x) -> "<div>#{x}</div>"
    metadataPrefix = metadataPrefix.join ''

    markdown = turndownService.turndown(metadataPrefix + text)

    @_fs.writeFileSync fullOutFileName, markdown, flag: 'w'



  ###*
  # @param {array} indexHtmlFiles Relative paths of index.html files from all parsed Confluence spaces
  # @param {string} dirOut Absolute path to a directory where to place converted MD files
  ###
  writeGlobalIndexFile: (indexHtmlFiles, dirOut) ->
    globalIndex = @_path.join dirOut, 'index.md'
    $content = @formatter.createListFromArray indexHtmlFiles
    text = @formatter.getHtml $content
    @writeMarkdownFile text, globalIndex


module.exports = App
