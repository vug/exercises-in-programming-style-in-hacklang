namespace ex08;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace HH;
use U;


function read_file(
  string $filepath,
  (function(mixed, mixed): void) $func,
): void {
  $text = \file_get_contents($filepath);
  $func($text, HH\fun('ex08\normalize'));
}

function filter_chars(
  string $text,
  (function(mixed, mixed): void) $func,
): void {
  $pattern = re"/[\W_]+/";
  $replaced = Regex\replace($text, $pattern, ' ');
  $func($replaced, HH\fun('ex08\scan'));
}

function normalize(string $text, (function(mixed, mixed): void) $func): void {
  $lowered = Str\lowercase($text);
  $func($lowered, HH\fun('ex08\remove_stop_words'));
}

function scan(string $text, (function(mixed, mixed): void) $func): void {
  $splitted = U\split_python($text);
  $func($splitted, HH\fun('ex08\frequencies'));
}

function remove_stop_words(
  vec<string> $words,
  (function(mixed, mixed): void) $func,
): void {
  $stop_words_text = \file_get_contents(U\stop_words_file_path);
  $stop_words = keyset(Str\split($stop_words_text, ','));
  $stop_words = Keyset\union(
    $stop_words,
    keyset(Str\split(U\ascii_lowercase, '')),
  );
  $filtered = Vec\filter($words, $w ==> !C\contains($stop_words, $w));
  $func($filtered, HH\fun('ex08\sort'));
}

function frequencies(
  vec<string> $words,
  (function(mixed, mixed): void) $func,
): void {
  $word_freqs = Dict\count_values($words);
  $func($word_freqs, HH\fun('ex08\print_text'));
}

function sort(
  dict<string, int> $word_freqs,
  (function(mixed, mixed): void) $func,
): void {
  $word_freqs_sorted = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  $func($word_freqs_sorted, HH\fun('ex08\no_op'));
}

function print_text(
  dict<string, int> $word_freqs,
  (function(mixed, mixed): void) $func,
): void {
  foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
    \print_r("{$word} - {$cnt}\n");
  }
  $func(null, null);
}

function no_op(null $_, null $_): void {}


function main(string $filepath): void {
  read_file($filepath, HH\fun('ex08\filter_chars'));
}
