namespace ex05;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use U;

function read_file(string $path_to_file): string {
  $text = \file_get_contents($path_to_file);
  return $text;
}

function filter_chars_and_normalize(string $str_data): string {
  $pattern = re"/[\W_]+/";
  $replaced = Regex\replace($str_data, $pattern, ' ');
  $lowered = Str\lowercase($replaced);
  return $lowered;
}

function scan(string $str_data): vec<string> {
  $splitted = Str\split($str_data, ' ');
  $splitted = Vec\filter($splitted, $w ==> $w !== '');
  return $splitted;
}

function remove_stop_words(vec<string> $word_list): vec<string> {
  $stop_words_text = \file_get_contents(U\stop_words_file_path);
  $stop_words = keyset(Str\split($stop_words_text, ','));
  $stop_words = Keyset\union($stop_words, keyset(Str\split(U\ascii_lowercase, '')));
  $filtered = Vec\filter($word_list, $w ==> !C\contains($stop_words, $w));
  return $filtered;
}

function frequencies(vec<string> $word_list): dict<string, int> {
  $word_freqs = dict[];
  foreach ($word_list as $word) {
    if (C\contains_key($word_freqs, $word)) {
      $word_freqs[$word] += 1;
    } else {
      $word_freqs[$word] = 1;
    }
  }
  return $word_freqs;
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  $sorted = Dict\sort_by($word_freqs, $v ==> -$v);
  return $sorted;
}

function print_top25(dict<string, int> $word_freqs): void {
  $top25 = Dict\take($word_freqs, 25);
  foreach ($top25 as $word => $freq) {
    \print_r($word." - ".$freq."\n");
  }
}

function main(string $file): void {
  print_top25(sort(frequencies(
    remove_stop_words(scan(filter_chars_and_normalize(read_file($file)))),
  )));
}
