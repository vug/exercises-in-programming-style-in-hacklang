namespace ex06;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};

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
  $stop_words_text = \file_get_contents("texts/stop_words.txt");
  $lowercase_chars_text = "abcdefghijklmnopqrstuvwxyz";
  $stop_words = Keyset\union(
    keyset(Str\split($stop_words_text, ',')),
    keyset(Str\split($lowercase_chars_text, '')),
  );
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
  $first = Dict\take($sorted, 25);
  return $first;
}

function main(string $file): void {
  \print_r(sort(frequencies(
    remove_stop_words(scan(filter_chars_and_normalize(read_file($file)))),
  )));
}
