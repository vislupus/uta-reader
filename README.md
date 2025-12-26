# 🎌 UtaReader

Learn Japanese through your favorite songs with morphological analysis powered by MeCab.

## Features

- **Morphological Analysis** - Automatic tokenization using MeCab
- **Furigana Display** - Reading hints above kanji
- **Dictionary Lookup** - Meanings from JMDict
- **Translation** - Bulgarian translation via Google Translate
- **Progress Tracking** - Mark learned words and track your progress
- **YouTube Integration** - Link songs to YouTube videos
- **Multiple Sources** - Add multiple lyrics source links
- **Ignore Syntax** - Use `{{text}}` to preserve but ignore parts like `[Verse 1]`

### System Requirements

- Windows 10 or later (64-bit)
- ~100 MB free space (for JMDict dictionary)
- Internet connection (for dictionary download and translations)

## Usage

### Adding a Song

1. Click **"New Song"**
2. Enter title and artist
3. (Optional) Add YouTube link and source links
4. Paste the lyrics
5. Click **"Analyze"**
6. Click **"Save Song"**

### Ignoring Text Parts

To keep markers like `[Verse 1]` visible but excluded from analysis:

```
{{[Verse 1]}}
きみの声が聞こえる
{{[Chorus]}}
愛してる
```


### Marking Learned Words

- Click a word to mark it as learned
- Click again to unmark
- Progress saves automatically