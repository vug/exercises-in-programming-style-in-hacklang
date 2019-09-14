namespace ex22;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use U;

function extract_words(string $filepath): vec<string> {
  invariant($filepath !== "", "I need a non-empty string!");


  $text = @\file_get_contents($filepath); // @ suppresses warning.
  invariant($text is string, "file does not exist.");
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowered = Str\lowercase($replaced);
  $splitted = U\split_python($lowered);
  return $splitted;
}

function remove_stop_words(vec<string> $words): vec<string> {
  $filepath = U\stop_words_file_path;
  $text = @\file_get_contents($filepath); // @ suppresses warning.
  invariant($text is string, "file does not exist.");
  $stop_words = keyset(
    Vec\concat(Str\split($text, ','), Str\split(U\ascii_lowercase, '')),
  );
  return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
}

function frequencies(vec<string> $words): dict<string, int> {
  invariant(C\count($words) > 0, "I need non-empty list!");

  return Dict\count_values($words);
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  invariant(C\count($word_freqs) > 0, "I need a non-empty dictionary!");

  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return $sorted_freqs;
}


function main(string $filepath): void {
  try {
    $sorted_freqs = sort(
      frequencies(remove_stop_words(extract_words($filepath))),
    );

    $sorted_freqs = TypeAssert\matches<dict<string, int>>($sorted_freqs);
    invariant(C\count($sorted_freqs) > 1, "I need more than 1 word.");
    foreach (Dict\take($sorted_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
