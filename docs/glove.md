![glove](http://i.imgur.com/ziiJIX6.png)

[![Build Status](https://travis-ci.org/stackmachine/glove.png?branch=master)](https://travis-ci.org/stackmachine/glove)

Glove is a LOVE 0.8.0 and 0.9.x compatibility library. It provides utility
functions for smoothing over the differences between LOVE versions with the
goal of writing Lua and LOVE code that is compatible on both versions.

## Migrating to Glove

Glove is a single Lua file, so it's easy to integrate. Once you've downloaded the
file, migrating involves only a few changes. First, load the module.

```lua
local glove = require 'glove'
```

Next, replace calls to backward-incompatible methods by changing `love` to
`glove`. For example, `love.filesystem.mkdir` no longer works in LOVE 0.9.x.

Change this code:

```lua
love.filesystem.mkdir('foo')
```

to

```lua
glove.filesystem.mkdir('foo')
```

The second code snippet will now work across both LOVE versions.

## Documentation

See the [documentation](https://github.com/stackmachine/glove/wiki/Supported-Methods-and-Modules) for supported methods.

## Developing

Glove is tested against both LOVE 0.8.0 and 0.9.x. To run these tests locally:

    make test
