namespace ex19\plugins\words2;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace U;
function extract_words(string $filepath): vec<string> {
  $text = Str\lowercase(\file_get_contents($filepath));
  $words = Vec\map(
    Regex\every_match($text, re"/[a-z]{2,}/"),
    $shape ==> $shape[0],
  );

  $stop_words = keyset(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
  );
  return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
}
