# SongDown

### A terminal-based Youtube song search and downloader using `youtube-dl`
##### SongDown allows you to search, choose and download songs, all from the terminal, without having to open a browser at all.

#### Usage
Just run the script to download any song from Youtube using the settings defined in `defaults.conf`.

#### Settings
The default settings in `defaults.conf`

#### Options
| Option                                   | Value                 | What it does                                               | Default               |
|------------------------------------------|-----------------------|------------------------------------------------------------|-----------------------|
| -v OR --video                            |                       | Downloads video in highest quality (720p max).       | Default = False       |
| -p OR --path                    | directory             | Defines path of downloaded file.                           | Default = ~/songdown/ |
| -r OR --results  | integer(less than 15) | Defines number of results to be shown from youtube search. | Default = 4           |
| -d OR --default <path>                   | directory             | Sets default path.                                         |                       |
