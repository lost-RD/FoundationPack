About
-----

TEsound is a sound manager for the Love2D framework. TEsound is intended
to make it easier to use sounds and music in your games.

It's under the [ZLIB
license](http://www.opensource.org/licenses/zlib-license.php). If you
use the library and your game ends up making a lot of money, its
creators politely request that you consider sending a little bit of it
their way.

### Download

[Direct from
Dropbox](http://dl.dropbox.com/u/3713769/web/Love/TLTools/TEsound.lua)

### Contact

-   [Forum Thread](http://love2d.org/forums/viewtopic.php?f=5&t=2334)
-   Ensayia - Ensayia@gmail.com
-   Taehl - SelfMadeSpirit@gmail.com

Setup
-----

Everything in the module is contained in the TEsound namespace, so don't
worry about it messing with your global variables. Memory and channel
management is automatic.

1.  Put TEsound.lua in your game's folder
2.  At the top of main.lua, add the line `require"TEsound"`
3.  In love.update(), add the line `TEsound.cleanup()`

FAQ
---

Q) How do I just play a sound?
:   A\) All you need to do is `TEsound.play(sound)`, where `sound` is either
    a [SoundData](SoundData "wikilink") or a string filepath to a sound file
    (like `"sounds/boom.ogg"`).

<!-- -->

Q) I have three different jump sounds, how can I play one at random?
:   A\) `TEsound.play(list)`, where `list` is a table like
    `{"jump1.ogg", "jump2.ogg", "jump3.ogg"}`.

<!-- -->

Q) Can I make it constantly play randomized music?
:   A\) Sure! `TEsound.playLooping(list)`. When one song ends, a new one from
    the list will automatically start playing.

<!-- -->

Q) Now how do I stop the music? / What are sound tags?
:   A\) The best way is to use TEsound's "tagging" feature. Simply put,
    TEsound lets you add one or more tags to each sound that's playing, and
    you can call various functions on all sounds with a given tag. So you
    could do this:
:   `TEsound.playLooping("song1.ogg", "music")`
:   `TEsound.stop("music")`
:   Sounds can have multiple tags if you desire (use a list:
    `TEsound.play(sound, {"something", "whatever", "lol"})`, and
    multiple sounds can share tags (if you call something like
    `TEsound.pitch("sfx", .5)`, all sounds with the "sfx" tag will
    immediately be low-pitched). Tags can also be unique, in case you
    want to work with a specific sound.

<!-- -->

Q) What if I want to change the volume/pitch of all sounds?
:   A\) That's what the special "all" tag is for. You don't need to give the
    tag to sounds, it's automatically applied to them. So if you wanted to
    cut the volume of everything in half, you just need to
    `TEsound.volume("all",.5)`.

<!-- -->

Q) I want to let the player choose different volume levels for sound effects, music, and voice-acting. Can TEsound handle it?
:   A\) Yep! You can set a volume multiplier for any tag with
    `TEsound.volume(tag, volume)`. Tag-volume changes take immediate effect
    (even on sounds that are already playing!). So you could use
    `TEsound.volume("voice", .75)`, and any sound with the "voice" tag would
    play at .75 volume. This is multiplied by the sound's own volume and
    what the "all" tag is set to - if you
    `TEsound.play("splat.ogg", "sfx", .5)`, and you've set the "sfx" and
    "all" tags to .6 and 1 volume, then the sound would play at .3 volume.

<!-- -->

Q) How do I pronounce the name of your module? "Tee ee sound"?
:   A\) That works, but I, personally, say "teh sound" ;)

Functions
---------

### Playback Functions

#### TEsound.play

``` {.lua}
TEsound.play(sound, tags, volume, pitch, func)
```

Plays a sound. Returns either the number of the channel the sound is
playing in, or nil and an error message.

#### TEsound.playLooping

``` {.lua}
TEsound.playLooping(sound, tags, n, volume, pitch)
```

Plays a sound which will repeat be repeated n times. If n isn't given,
it will loop until stopped manually with TEsound.stop. Returns either
the number of the channel the sound is playing in, or nil and an error
message.

### Sound Modification Functions

#### TEsound.volume

``` {.lua}
TEsound.volume(channel, volume)
```

Sets the volume of channel or tag and its loops (if any).

#### TEsound.volume

``` {.lua}
TEsound.volume(tag, volume)
```

Sets the volume of channel or tag and its loops (if any).

#### TEsound.pitch

``` {.lua}
TEsound.pitch(channel, pitch)
```

Sets the pitch of channel or tag and its loops (if any).

#### TEsound.pitch

``` {.lua}
TEsound.pitch(tag, pitch)
```

Sets the pitch of channel or tag and its loops (if any).

#### TEsound.pause

``` {.lua}
TEsound.pause(channel)
```

Pauses a channel or tag. Use TEsound.resume to unpause.

#### TEsound.pause

``` {.lua}
TEsound.pause(tag)
```

Pauses a channel or tag. Use TEsound.resume to unpause.

#### TEsound.resume

``` {.lua}
TEsound.resume(channel)
```

Resumes a channel or tag from a pause.

#### TEsound.resume

``` {.lua}
TEsound.resume(tag)
```

Resumes a channel or tag from a pause.

#### TEsound.stop

``` {.lua}
TEsound.stop(channel, finish)
```

Stops a sound channel or tag either immediately or when finished, and
prevents it from looping.

#### TEsound.stop

``` {.lua}
TEsound.stop(tag, finish)
```

Stops a sound channel or tag either immediately or when finished, and
prevents it from looping.

### Utility Functions

#### TEsound.cleanup

``` {.lua}
TEsound.cleanup()
```

Cleans up finished sounds, freeing memory. It's highly recommended you
call this in love.update(). If not called, memory and channels won't be
freed, and sounds won't loop.

#### TEsound.volume

``` {.lua}
TEsound.volume(tag, volume)
```

Change the volume level for a specified tag. Volume changes take effect
immediately and last until changed again. This is recommended for
changing entire categories of sounds, so you can independently adjust
the volume of all sound effects, music, etc. (but don't forget to tag
your sounds appropriately). If a sound has multiple tags with set
volumes, the first one (in the order of its tag list) will be used.

#### TEsound.tagPitch

``` {.lua}
TEsound.tagPitch(tag, volume)
```

Change the pitch for a specified tag. Changes take effect immediately
and last until changed again. This is recommended for changing entire
categories of sounds. If a sound has multiple tags with set pitches, the
first one (in the order of its tag list) will be used.

### Internal Functions

#### TEsound.findTag

``` {.lua}
TEsound.findTag(tag)
```

Returns a list of all sound channels with a given tag.

#### TEsound.findVolume

``` {.lua}
TEsound.findVolume(tag)
```

Returns a volume level for a given tag or tags, or 1 if the tag(s)'s
volume hasn't been set. If a list of tags is given, it will return the
level of the first tag with a setting.

#### TEsound.findPitch

``` {.lua}
TEsound.findPitch(tag)
```

Returns a pitch level for a given tag or tags, or 1 if the tag(s)'s
pitch hasn't been set.

{{\#set:LOVE Version=0.7.0}} {{\#set:Description=A sound manager that
makes it easy to use sound and music}} {{\#set:License=ZLIB license}}
{{\#set:Author=User:Taehl}} {{\#set:Author=User:Ensayia}}

<Category:Libraries>

