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

### breaks

Type: `boolean`
Default: `true`

Enable GFM [line breaks][breaks].
This option requires the `gfm` option to be true.

### tables

Type: `boolean`
Default: `true`

Enable GFM [tables][tables].
This option requires the `gfm` option to be true.

