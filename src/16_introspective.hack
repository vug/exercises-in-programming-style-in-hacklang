namespace ex16;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function extract_words(string $_): vec<string> {
  $call_stack = \debug_backtrace();
  $caller = $call_stack[1];
  if ($caller['function'] !== "ex16\main") {
    return vec[];
  }

  // https://hhvm.com/blog/2019/04/09/hhvm-4.1.0.html says "get_defined_vars() has been removed"
  // no method to get the variables defined in the scope. Utilize call stack.
  $callee = $call_stack[0];
  $filepath = TypeAssert\string($callee['args'][0]);
  $text = \file_get_contents($filepath);
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowered = Str\lowercase($replaced);
  $splitted = U\split_python($lowered);

  $stop_words = read_stop_words();
  return Vec\filter($splitted, $word ==> !C\contains_key($stop_words, $word));
}

function read_stop_words(): keyset<string> {
  $call_stack = \debug_backtrace();
  $caller = $call_stack[1];
  if ($caller['function'] === "ex16\extract_words") {
    return keyset[];
  }

  $stop_words = keyset(Vec\concat(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
    Str\split(U\ascii_lowercase, ''),
  ));
  return $stop_words;
}


function frequencies(vec<string> $_): dict<string, int> {
  $call_stack = \debug_backtrace();
  $caller = $call_stack[1];
  if ($caller['function'] !== "ex16\main") {
    return dict[];
  }

  $callee = $call_stack[0];
  $words = TypeAssert\matches<vec<string>>($callee['args'][0]);
  $word_freqs = Dict\count_values($words);
  return $word_freqs;
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  $call_stack = \debug_backtrace();
  $caller = $call_stack[1];
  if ($caller['function'] !== "ex16\main") {
    return dict[];
  }

  $callee = $call_stack[0];
  $word_freqs = TypeAssert\matches<dict<string, int>>($callee['args'][0]);
  return Dict\sort_by($word_freqs, $cnt ==> -$cnt);
}

function main(string $filepath): void {
  try {
    $word_list = extract_words($filepath);
    $word_freqs = frequencies($word_list);
    $sorted = sort($word_freqs); // |> \print_r($$);
    foreach (Dict\take($sorted, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
