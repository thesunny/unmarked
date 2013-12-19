/*
 
You can use this to convert a DOM element or a HTML string to markdown.
 
Usage examples:
var markdown = toMarkdown(document.getElementById("content"));
 
// With jQuery you can easily convert HTML strings
var markdown = toMarkdown($("<ul><li>Hi!</li></ul>")[0]);
 
*/
function markdownEscape(text) {
  if (!text) {
    return '';
  }
  return text.replace(/\s+/g, " ").replace(/[\\\-*_>#]/g, "\\$&");
}

function cleanTrailingNewlines(markdown) {
  return markdown.replace(/\n+$/, "");
}

function prefixLines(text, prefix) {
  return prefix + text.replace(/\n/g, "\n" + prefix);
}

function repeat(str, times) {
  return (new Array(times + 1)).join(str)
}

function childsToMarkdown(tree, mode) {
  var res = "";
  for (var i = 0, l = tree.childNodes.length; i < l; ++i) {
    res += nodeToMarkdown(tree.childNodes[i], mode);
  }
  return res;
}

function nodeToMarkdown(tree, mode) {
  var nl = "\n\n";
  if (tree.nodeType == 3) { // Text node
    var text = tree.nodeValue.replace(/^\s+/, "");
    return markdownEscape(text)
  } else if (tree.nodeType == 1) {

    // Block Mode
    // Most of these methods call return immediately after execution in block
    // mode.
    if (mode == "block") {
      switch (tree.tagName.toLowerCase()) {
      case "br":
        // TODO: The spaces are not required for GFM so should probably be
        // used only if the option is set
        return "  " + "\n";
      case "hr":
        return nl + "---" + nl;
        // Block container elements
      case "p":
      case "div":
      case "section":
      case "address":
      case "center":
        return nl + childsToMarkdown(tree, "block") + nl;
      case "ul":
        return nl + childsToMarkdown(tree, "u") + nl;
      case "ol":
        return nl + childsToMarkdown(tree, "o") + nl;
      case "pre":
        return nl + prefixLines(tree.innerText, "    ") + nl;
      case "code":
        if (tree.childNodes.length == 1 && tree.childNodes[0].nodeType == 3) {
          break; // use the inline format
        }
        return nl + "    " + childsToMarkdown(tree, "inline") + nl;
      case "h1":
      case "h2":
      case "h3":
      case "h4":
      case "h5":
      case "h6":
      case "h7":
        return nl + repeat("#", +tree.tagName[1]) + " " + childsToMarkdown(tree, "inline") + nl;
      case "blockquote":
        return nl + prefixLines(cleanTrailingNewlines(childsToMarkdown(tree, "block")), "> ") + nl;
      }
    }

    // List Modes
    // Added support for improperly nested list items
    if (/^[ou]+$/.test(mode)) {
      if (tree.tagName == "LI") {
        return "\n" + repeat("  ", mode.length - 1) + (mode[mode.length - 1] == "o" ? "1. " : "- ") + childsToMarkdown(tree, mode + "l");
      }
    }
    if (/^[ou]+l?$/.test(mode)) {
      var listMode = mode.replace(/l$/, "");
      if (tree.tagName == "UL") {
        return childsToMarkdown(tree, listMode + "u");
      } else if (tree.tagName == "OL") {
        return childsToMarkdown(tree, listMode + "o");
      }
    }

    // Inline Mode
    switch (tree.tagName.toLowerCase()) {
    case "strong":
    case "b":
      return "**" + childsToMarkdown(tree, "inline") + "**";
    case "em":
    case "i":
      return "_" + childsToMarkdown(tree, "inline") + "_";
    case "code": // Inline version of code
      return "`" + childsToMarkdown(tree, "inline") + "`";
    case "a":
      // Added support for automated links here
      var inlineMarkup = childsToMarkdown(tree, "inline");
      var href = tree.getAttribute("href");
      if (inlineMarkup == href) {
        return "<" + href + ">";
      } else {
        return "[" + inlineMarkup + "](" + href + ")";
      }
    case "img":
      return " ![" + markdownEscape(tree.getAttribute("alt")) + "](" + tree.getAttribute("src") + ") ";
    case "script":
    case "style":
    case "meta":
      return "";
    default:
      console.log("[toMarkdown] - undefined element " + tree.tagName)
      return childsToMarkdown(tree, mode);
    }
  }
}

function toMarkdown(node) {
  return nodeToMarkdown(node, "block").replace(/[\n]{2,}/g, "\n\n").replace(/^[\n]+/, "").replace(/[\n]+$/, "");
}