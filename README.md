# README


## Starting the TestRunner

To start the testrunner on port 3000, use

    bundle exec rake server


## Options

The options are compatible with those in the Marked markdown parser here:

[https://github.com/chjj/marked](https://github.com/chjj/marked)

### gfm

Type: `boolean`
Default: `true`

Enable [GitHub flavored markdown][gfm].

### tables

Type: `boolean`
Default: `true`

Enable GFM [tables][tables].
This option requires the `gfm` option to be true.

### breaks

Type: `boolean`
Default: `false`

Enable GFM [line breaks][breaks].
This option requires the `gfm` option to be true.

### pedantic

Type: `boolean`
Default: `false`

Conform to obscure parts of `markdown.pl` as much as possible. Don't fix any of
the original markdown bugs or poor behavior.

### sanitize

Type: `boolean`
Default: `false`

Sanitize the output. Ignore any HTML that has been input.

### smartLists

Type: `boolean`
Default: `true`

Use smarter list behavior than the original markdown. May eventually be
default with the old behavior moved into `pedantic`.

### smartypants

Type: `boolean`
Default: `false`

Use "smart" typograhic punctuation for things like quotes and dashes.