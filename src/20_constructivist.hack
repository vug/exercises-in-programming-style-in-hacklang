namespace ex20;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use U;

/**
 * Hack does everything in its hand to force programmers not to 
 * use `mixed`s and run-time checking of non-privimive types. 
 * This function imitates Python's `type`.
 */
function is_of_type<reify Tx>(mixed $x): bool {
  try {
    TypeAssert\matches<Tx>($x);
    return true;
  } catch (TypeAssert\IncorrectTypeException $ex) {
    return false;
  }
}

function extract_words(mixed $filepath): vec<string> {
  if ($filepath === null || !$filepath is string) {
    return vec[];
  }

  try {
    $text = @\file_get_contents($filepath); // @ suppresses warning.
    invariant($text is string, "file does not exist.");
  } catch (\Exception $ex) {
    \print_r("IO error({$ex->getCode()}) when opening {$filepath}: {$ex
      ->getMessage()}\n");
    return vec[];
  }
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowered = Str\lowercase($replaced);
  $splitted = U\split_python($lowered);
  return $splitted;
}

function remove_stop_words(mixed $words): vec<string> {
  if ($words === null || !is_of_type<vec<string>>($words)) {
    return vec[];
  }
  $words = TypeAssert\matches<vec<string>>($words);

  try {
    $filepath = U\stop_words_file_path;
    $text = @\file_get_contents($filepath); // @ suppresses warning.
    invariant($text is string, "file does not exist.");
  } catch (\Exception $ex) {
    \print_r("IO error({$ex->getCode()}) when opening {$filepath}: {$ex
      ->getMessage()}\n");
    return $words;
  }

  $stop_words = keyset(
    Vec\concat(Str\split($text, ','), Str\split(U\ascii_lowercase, '')),
  );
  return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
}

function frequencies(mixed $words): dict<string, int> {
  if ($words === null || !is_of_type<vec<string>>($words)) {
    return dict[];
  }
  $words = TypeAssert\matches<vec<string>>($words);

  return Dict\count_values($words);
}

function sort(mixed $word_freqs): dict<string, int> {
  if ($word_freqs === null || !is_of_type<dict<string, int>>($word_freqs)) {
    return dict[];
  }
  $word_freqs = TypeAssert\matches<dict<string, int>>($word_freqs);

  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return $sorted_freqs;
}


function main(mixed ...$args): void {
  if (C\count($args) === 0 || !$args[0] is string) {
    $filepath = "texts/small_input.txt";
  } else {
    $filepath = TypeAssert\string($args[0]);
  }

  try {
    $sorted_freqs = sort(
      frequencies(remove_stop_words(extract_words($filepath))),
    );
    foreach (Dict\take($sorted_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
