namespace ex18;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

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

function frequencies(vec<string> $words): dict<string, int> {
  return Dict\count_values($words);
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  return Dict\sort_by($word_freqs, $cnt ==> -$cnt);
}

function profile<Treturn>(
  (function(mixed...): Treturn) $func,
): (function(mixed...): Treturn) {
  $profile_wrapper = (mixed ...$args): Treturn ==> {
    $start_time = \microtime();
    $return_value = $func(...$args);
    $end_time = \microtime();
    $elapsed = $end_time - $start_time;
    $rf = new \ReflectionFunction($func);
    \print_r("{$rf->name} took {$elapsed} seconds.\n");
    return $return_value;
  };
  return $profile_wrapper;
}

function main(string $filepath): void {
  try {
    $tracked_functions = vec[
      HH\fun('ex18\extract_words'),
      HH\fun('ex18\frequencies'),
      HH\fun('ex18\sort'),
    ];
    // Hack does not allow redefining functions in run-time.
    // Define new functions that wraps existing ones instead.
    $profiled_functions = Vec\map($tracked_functions, $func ==> profile($func));

    $val = $filepath;
    foreach ($profiled_functions as $pfunc) {
      $val = $pfunc($val);
    }

    $sorted = TypeAssert\matches<dict<string, int>>($val);
    foreach (Dict\take($sorted, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
