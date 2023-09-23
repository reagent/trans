# Video Transcoding Tooling

Tooling to help transcode video sources to a configured destination.

## Prerequisites

You'll need to have a functioning installation of [`HandbrakeCLI`][handbrake]
and probably `ffmpeg` as well. These can be installed from [homebrew].

## Installation

You can fetch and install directly from the repository. A global installation
is preferred.

```
git clone https://github.com/reagent/trans.git && \
  cd trans && gem build && gem install trans-*.gem
```

## Usage

This library takes a two-step approach to transcoding your video files by first
scanning a source directory for directories matching a certain pattern
(`<movie-name> (<movie-year>)`) that contain one or more [Matroska] video
files. Once the directory is scanned and a configuration generated, a separate
transcoding command can be run against the configuration.

### Scanning Sources

This is the first step to configure any sources that you wish to transcode:

```
mkv-scanner --source ~/Movies --destination ~/Transcoded movies.yml
```

The `movies.yml` file will now contain all sources that need transcoding -- it
will exclude sources that already have a configuration stanza and those that are
already present in the destination directory. For example, with this directory
structure:

```
.
├── Movies
│   ├── Taxi Driver (1976)
│   │   └── t_00.mkv
│   └── The Goonies (1985)
│       └── t_01.mkv
└── Transcoded
    └── The Goonies (1985)
        └── The_Goonies.mkv
```

This command:

```
mkv-scanner --source Movies --destination Transcoded movies.yml
```

Will generate this configuration:

```yaml
---
configured: []
pending:
  - source_file: Taxi Driver (1976)/t_00.mkv
    movie:
      title: Taxi Driver
      year: "1976"
    transcoding_options:
      crop: auto
      audio_track: "1"
      subtitle_track: scan
```

The `mkv-scanner` command is designed to be idempotent when given the same
source and destination directories.

### Transcoding Files

In the above configuration, you'll notice that all sources are grouped under the
`pending` section. To configure a source to be transcoded, simply move it into the
`configured` section and change any defaults. Then you can run the transcoding
command:

```
mkv-transcoder --source Movies --destination Transcoded  movies.yml
```

This will invoke [`Handbrake`][handbrake] on each of the configured sources and
output them to the configured destination directory.

## Credits

Thanks to [Don Melton] and his [Video Transcoding tools][video_transcoding] that
provide most of the transcoding functionality.

[handbrake]: https://handbrake.fr/
[homebrew]: https://brew.sh/
[Matroska]: https://en.wikipedia.org/wiki/Matroska
[Don Melton]: https://github.com/donmelton
[video_transcoding]: https://github.com/donmelton/video_transcoding
