namespace ex19\plugins\words1;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace U;

function extract_words(string $filepath): vec<string> {
  $text = \file_get_contents($filepath);
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowered = Str\lowercase($replaced);
  $splitted = U\split_python($lowered);

  $stop_words = keyset(Vec\concat(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
    Str\split(U\ascii_lowercase, ''),
  ));
  return Vec\filter($splitted, $word ==> !C\contains_key($stop_words, $word));
}
