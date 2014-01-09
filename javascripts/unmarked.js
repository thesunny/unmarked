var Unmarked;

Unmarked = (function() {

  function Unmarked(options) {
    var o;
    this.options = options != null ? options : {};
    o = this.options;
    if (!(o.gfm != null)) o.gfm = true;
    if (!(o.tables != null)) o.tables = o.gfm;
    if (!(o.breaks != null)) o.breaks = o.gfm;
  }

  Unmarked.prototype.leadingSpaceRegexp = /^\s+/;

  Unmarked.prototype.escape = function(text) {
    if (!text) return "";
    text = text.replace(/\s+/g, " ").replace(/[\\\-*_>#]/g, "\\$&");
    return text;
  };

  Unmarked.prototype.cleanTrailingNewlines = function(markdown) {
    return markdown.replace(/\n+$/, "");
  };

  Unmarked.prototype.prefixLines = function(text, prefix) {
    return prefix + text.replace(/\n/g, "\n" + prefix);
  };

  Unmarked.prototype.repeat = function(str, times) {
    return (new Array(times + 1)).join(str);
  };

  Unmarked.prototype.childsToMarkdown = function(tree, mode) {
    var firstInLine, i, l, res, s;
    res = "";
    firstInLine = true;
    i = 0;
    l = tree.childNodes.length;
    while (i < l) {
      s = this.nodeToMarkdown(tree.childNodes[i], mode, firstInLine);
      firstInLine = /\n$/.test(s);
      res += s;
      ++i;
    }
    return res;
  };

  Unmarked.prototype.nodeToMarkdown = function(tree, mode, firstInLine) {
    var href, inlineMarkup, listMode, nl, tag, text;
    nl = "\n\n";
    if (tree.nodeType === 3) {
      text = tree.nodeValue;
      if (firstInLine) text = text.replace(this.leadingSpaceRegexp, "");
      return this.escape(text);
    } else if (tree.nodeType === 1) {
      tag = tree.tagName.toLowerCase();
      if (mode === "block") {
        switch (tag) {
          case "br":
            if (this.options.breaks) {
              return "\n";
            } else {
              return "  \n";
            }
            break;
          case "hr":
            return nl + "---" + nl;
          case "p":
          case "div":
          case "section":
          case "address":
          case "center":
            return nl + this.childsToMarkdown(tree, "block") + nl;
          case "ul":
            return nl + this.childsToMarkdown(tree, "u") + nl;
          case "ol":
            return nl + this.childsToMarkdown(tree, "o") + nl;
          case "pre":
            return nl + this.prefixLines(tree.innerText, "    ") + nl;
          case "code":
            if (tree.childNodes.length === 1 && tree.childNodes[0].nodeType === 3) {
              break;
            }
            return nl + "    " + this.childsToMarkdown(tree, "inline") + nl;
          case "h1":
          case "h2":
          case "h3":
          case "h4":
          case "h5":
          case "h6":
          case "h7":
            return nl + this.repeat("#", +tree.tagName[1]) + " " + this.childsToMarkdown(tree, "inline") + nl;
          case "blockquote":
            return nl + this.prefixLines(this.cleanTrailingNewlines(this.childsToMarkdown(tree, "block")), "> ") + nl;
          case "table":
            if (this.options.tables) {
              return nl + this.childsToMarkdown(tree, "table") + nl;
            } else {
              return nl + this.childsToMarkdown(tree, "block") + nl;
            }
        }
      }
      if (/^[ou]+$/.test(mode) ? tree.tagName === "LI" : void 0) {
        return "\n" + this.repeat("  ", mode.length - 1) + (mode[mode.length - 1] === "o" ? "1. " : "- ") + this.childsToMarkdown(tree, mode + "l");
      }
      if (/^[ou]+l?$/.test(mode)) {
        listMode = mode.replace(/l$/, "");
        if (tree.tagName === "UL") {
          return this.childsToMarkdown(tree, listMode + "u");
        } else {
          if (tree.tagName === "OL") {
            return this.childsToMarkdown(tree, listMode + "o");
          }
        }
      }
      if (mode === "table") {
        if (tag === "tr") return "|" + this.childsToMarkdown(tree, "tr") + "\n";
      }
      if (mode === "tr") {
        switch (tag) {
          case "th":
          case "td":
            return (tree.innertText || tree.textContent) + "|";
        }
      }
      switch (tag) {
        case "strong":
        case "b":
          return "**" + this.childsToMarkdown(tree, "inline") + "**";
        case "em":
        case "i":
          return "_" + this.childsToMarkdown(tree, "inline") + "_";
        case "code":
          return "`" + this.childsToMarkdown(tree, "inline") + "`";
        case "a":
          inlineMarkup = this.childsToMarkdown(tree, "inline");
          href = tree.getAttribute("href");
          if (inlineMarkup === href) {
            return "<" + href + ">";
          } else {
            return "[" + inlineMarkup + "](" + href + ")";
          }
          break;
        case "img":
          return " ![" + this.escape(tree.getAttribute("alt")) + "](" + tree.getAttribute("src") + ") ";
        case "script":
        case "style":
        case "meta":
          return "";
        default:
          return this.childsToMarkdown(tree, mode);
      }
    }
  };

  Unmarked.prototype.toMarkdown = function(node) {
    return this.nodeToMarkdown(node, "block").replace(/([\n]\s*)+[\n]/g, "\n\n").replace(/^[\n]+/, "").replace(/[\n]+$/, "");
  };

  return Unmarked;

})();

this.Unmarked = Unmarked;

if (window.jQuery) {
  window.jQuery.fn.unmark = function(options) {
    var node;
    node = this[0];
    return new Unmarked(options).toMarkdown(node);
  };
}
