# Introduction

`go-vid` is a script to help host videos on a Hugo website.

# Installation

```sh
mkdir -p ~/.local/bin
wget https://git.sr.ht/~rehandaphedar/go-vid/blob/main/main.sh -O ~/.local/bin/go-vid
chmod +x ~/.local/bin/go-vid
```

# Configuration

## Directory Structure

`go-vid` expects this kind of directory structure:

```
website
├── archetypes
├── assets
├── content
├── data
├── i18n
├── layouts
├── go-vid
├── public
├── static
└── themes
```

This is the standard Hugo directory structure, with an extra `go-vid` folder.

You can edit this structure in the script.

## Hugo Configuration

To enable `go-vid` to function properly, you should add this bit of configuration to `hugo.toml`:

```toml
[markup.goldmark.renderer]
	unsafe = true

[mediaTypes."application/atom+xml"]
  suffixes = ["atom"]

[outputFormats.ATOM]
  name = "ATOM"
  mediaType = "application/atom+xml"
  baseName = "feed"
  rel = "alternate"
  isPlainText = false
  isHTML = false
  permalinkable = false

[outputs]
  home = ["HTML", "ATOM"]
  section = ["HTML", "ATOM"]
  taxonomy = ["HTML", "ATOM"]
  term = ["HTML", "ATOM"]
```


# Usage

## Create A Video

Run `go-vid create`, enter the title, and pick the video file.
You will be presented with a markdown file, where you can add the description.

## Transode Videos

Run `go-vid transcode`. This goes through all videos on `go-vid/` and if they are not already transcoded, transcodes them. Also generates `.torrent` files for newly transcoded videos.
If you want a video to be re-transcoded, simply delete the relevant file from `static/videos/`.

The resolutions to transcode to can be changed by editing the script.
By default, `lf` is used as a video file picker. You can edit this in the script's `get_video` function.

## Export Videos

Run `go-vid export`. This generates Hugo compatible markdown files in `content/videos/`.
# Dependencies

- `slugify`
- `jq`
- `yq`
- `lf` (Another file picker can be configured)
- `ffmpeg`
- `mktorrent`
