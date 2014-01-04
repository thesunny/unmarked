convert = (html) ->
  (new Unmarked()).toMarkdown($("<div>#{html}</div>")[0])

p = (text) ->
  console.log text

beforeEach ->
  @addMatchers
    toInclude: (expected) ->
      this.actual.indexOf(expected) != -1

describe "Unmarked", ->
  
  it "converts headings", ->
    s = convert """
      <h1>Heading 1</h1>
      <h2>Heading 2</h2>
      <h3>Heading 3</h3>
      <h4>Heading 4</h4>
      <h5>Heading 5</h5>
      <h6>Heading 6</h6>
      <h7>Heading 7</h7>
    """
    expect(s).toInclude("# Heading 1")
    expect(s).toInclude("# Heading 2")
    expect(s).toInclude("# Heading 3")
    expect(s).toInclude("# Heading 4")
    expect(s).toInclude("# Heading 5")
    expect(s).toInclude("# Heading 6")
    expect(s).toInclude("# Heading 7")

  it "collapses blocks", ->
    s = convert """
      <p>paragraph</p>
      <p></p>
      <p></p>
      <p></p>
      <p>paragraph</p>
    """
    expect(s).toInclude("""
      paragraph

      paragraph
    """)

  it "converts inline styling", ->
    s = convert """
      it has <strong>strong</strong> and 
      it has <b>b</b> and 
      it has <em>em</em> and 
      it has <i>i</i> and 
      it has <code>code</code>
    """
    expect(s).toInclude "it has **strong** and it has **b** and it has _em_ and it has _i_ and it has `code`"
  
  it "handles spaces between inline styles", ->
    s = convert """
      it has <strong>strong</strong> <b>b</b> <em>em</em> <i>i</i> <code>code</code>.
    """

  it "converts links", ->
    s = convert """
      This links to <a href="http://google.com/">Google</a>.
      This links to <a href="http://yahoo.com/">http://yahoo.com/</a>.
    """
    expect(s).toInclude "This links to [Google](http://google.com/)."
    expect(s).toInclude "This links to <http://yahoo.com/>."

  it "treats certain things as plain blocks", ->
    s = convert """
      <p>p block</p>
      <div>div block</div>
      <section>section block</section>
      <address>address block</address>
      <center>center block</center>
    """
    expect(s).toInclude """
      p block

      div block

      section block

      address block

      center block
    """

  it "ignores unknown things", ->
    s = convert """
      it doesn't know about <unknown>unknown</unknown>.
    """
    expect(s).toInclude "it doesn't know about unknown."

  it "handles inline styles in headings", ->
    s = convert """
      <h1>a <b>bold</b> <em>emphasized</em> heading</h1>
    """
    expect(s).toInclude "# a **bold** _emphasized_ heading"

  it "handles nested blockquotes", ->
    s = convert """
      before
      <blockquote>
        blockquote before
        <blockquote>inner</blockquote>
        blockquote after
      </blockquote>
      after
    """
    expect(s).toInclude """
      before 
      
      > blockquote before 
      > 
      > > inner
      > 
      > blockquote after 
      
      after
    """

  it "handles br using 2 spaces at end of line", ->
    s = convert """
      on<br>its<br>
      own<br>line
    """
    expect(s).toInclude """
      on  
      its  
      own  
      line
    """
  
  it "handles images", ->
    s = convert """
      <p>
        image: <img src="http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif">
      </p>
      <p>
        image: <img src="http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif" width=640 height=480 alt="image 2">
      </p>
    """
    # TODO: There should only be one space after image:
    expect(s).toInclude("image:  ![](http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif)")
    expect(s).toInclude("image:  ![image 2](http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif)")

  it "handles pre", ->
    s = convert """
      The following is code:
      <pre>  code
       is formatted
      exactly</pre>
      after code
    """
    # TODO: THere is a space after `code: ` which needs to be cleaned up.
    # We need to join text nodes together and process them together to make this work
    expect(s).toInclude "\n\n      code\n     is formatted\n    exactly"

  it "strips out script, style and meta", ->
    s = convert """
      before
      <style>
        p { font-size: 13px; }
      </style>
      <script>alert("It's annoying!")</script>
      <meta name="description" content="Description goes here.">
      after
    """
    expect(s).toInclude("before")
    expect(s).toInclude("after")

  it "converts simple lists", ->
    s = convert """
      before
      <ul>
        <li>item
        <li>item
      </ul>
      <ol>
        <li>item
        <li>item
      </ol>
      after
    """
    # TODO: There is a space behind `before `, `item `, etc. that should be
    # cleaned up.
    expect(s).toInclude """
      before 

      - item 
      - item 

      1. item 
      1. item 

      after
    """

  it "converts nested lists", ->
    s = convert """
      before
      <ul>
        <li>item
        <ol>
          <li>item
          <li>item
          <ul>
            <li>item
            <li>item
          </ul>
          </li>
        </ol>
        <li>item
        <li>item
      </ul>
      after
    """
    expect(s).toInclude """
      before 

      - item 
        1. item 
        1. item 
          - item 
          - item    
      - item 
      - item 

      after
    """

  it "escapes text", ->
    s = convert "\\-*_"
    expect(s).toEqual("\\\\\\-\\*\\_")

  it "creates a jQuery plugin", ->
    s = $("<h1>Heading</h1>").unmark();
    expect(s).toEqual("# Heading")