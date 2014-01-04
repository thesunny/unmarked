class Unmarked

  constructor: (@options={}) ->
    # Shortcut to @options
    o = @options
    # Use Github Flavored Markdown?
    o.gfm = true if !o.gfm?
    # Enable tables support?
    o.tables = o.gfm if !o.tables?
    # Enable breaks (without two trailing spaces)
    o.breaks = o.gfm if !o.breaks?

  leadingSpaceRegexp: /^\s+/

  escape: (text) ->
    return ""  unless text
    # replace multiple spaces with a single space.
    # convert \-*_
    text = text.replace(/\s+/g, " ").replace(/[\\\-*_>#]/g, "\\$&")
    text

  cleanTrailingNewlines: (markdown) ->
    markdown.replace /\n+$/, ""

  prefixLines: (text, prefix) ->
    prefix + text.replace(/\n/g, "\n" + prefix)

  repeat: (str, times) ->
    (new Array(times + 1)).join str

  childsToMarkdown: (tree, mode) ->
    res = ""
    firstInLine = true
    i = 0
    l = tree.childNodes.length

    while i < l
      s = @nodeToMarkdown(tree.childNodes[i], mode, firstInLine)
      firstInLine = (/\n$/.test(s))
      res += s
      ++i
    res

  nodeToMarkdown: (tree, mode, firstInLine) ->


    nl = "\n\n"
    if tree.nodeType is 3 # Text node
      text = tree.nodeValue
      
      # trim any leading space if this is the first text node in the line.
      text = text.replace(@leadingSpaceRegexp, "")  if firstInLine
      
      # TODO: we also need to trim trailing spacing if this is the last text
      # node in the line.
      @escape text
    else if tree.nodeType is 1

      tag = tree.tagName.toLowerCase()
      
      # Block Mode
      # Most of these methods call return immediately after execution in block
      # mode.
      if mode is "block"
        switch tag
          when "br"
            # TODO: The spaces are not required for GFM so should probably be
            # used only if the breaks option is set
            if @options.breaks
              return "\n"
            else
              return "  \n"
          when "hr"
            return nl + "---" + nl
          
          # Block container elements
          when "p", "div", "section", "address", "center"
            return nl + @childsToMarkdown(tree, "block") + nl
          when "ul"
            return nl + @childsToMarkdown(tree, "u") + nl
          when "ol"
            return nl + @childsToMarkdown(tree, "o") + nl
          when "pre"
            return nl + @prefixLines(tree.innerText, "    ") + nl
          when "code"
            break  if tree.childNodes.length is 1 and tree.childNodes[0].nodeType is 3 # use the inline format
            return nl + "    " + @childsToMarkdown(tree, "inline") + nl
          when "h1", "h2", "h3", "h4", "h5", "h6", "h7"
            return nl + @repeat("#", +tree.tagName[1]) + " " + @childsToMarkdown(tree, "inline") + nl
          when "blockquote"
            return nl + @prefixLines(@cleanTrailingNewlines(@childsToMarkdown(tree, "block")), "> ") + nl
          when "table"
            if @options.tables
              return nl + @childsToMarkdown(tree, "table") + nl
            else
              return nl + @childsToMarkdown(tree, "block") + nl
      
      # List Modes
      # Added support for improperly nested list items
      return "\n" + @repeat("  ", mode.length - 1) + ((if mode[mode.length - 1] is "o" then "1. " else "- ")) + @childsToMarkdown(tree, mode + "l")  if tree.tagName is "LI"  if /^[ou]+$/.test(mode)
      if /^[ou]+l?$/.test(mode)
        listMode = mode.replace(/l$/, "")
        if tree.tagName is "UL"
          return @childsToMarkdown(tree, listMode + "u")
        else return @childsToMarkdown(tree, listMode + "o")  if tree.tagName is "OL"

      # Table mode
      if mode == "table"
        if tag == "tr"
          return "|" + @childsToMarkdown(tree, "tr") + "\n"

      if mode == "tr"
        switch tag
          when "th", "td"
            return (tree.innertText || tree.textContent) + "|"
      
      # Inline Mode
      switch tag
        when "strong", "b"
          "**" + @childsToMarkdown(tree, "inline") + "**"
        when "em", "i"
          "_" + @childsToMarkdown(tree, "inline") + "_"
        when "code" # Inline version of code
          "`" + @childsToMarkdown(tree, "inline") + "`"
        when "a"
          
          # Added support for automated links here
          inlineMarkup = @childsToMarkdown(tree, "inline")
          href = tree.getAttribute("href")
          if inlineMarkup is href
            "<" + href + ">"
          else
            "[" + inlineMarkup + "](" + href + ")"
        when "img"
          " ![" + @escape(tree.getAttribute("alt")) + "](" + tree.getAttribute("src") + ") "
        when "script", "style", "meta"
          ""
        else
          
          # console.log("[toMarkdown] - undefined element " + tree.tagName)
          @childsToMarkdown tree, mode

  toMarkdown: (node) ->
    
    # console.log(nodeToMarkdown(node, "block"))
    @nodeToMarkdown(node, "block").replace(/([\n]\s*)+[\n]/g, "\n\n").replace(/^[\n]+/, "").replace /[\n]+$/, ""

this.Unmarked = Unmarked #convert: toMarkdown

# add the jQuery plugin unmark if jQuery is defined
if window.jQuery
  window.jQuery.fn.unmark = (options) ->
    node = this[0]
    new Unmarked(options).toMarkdown node