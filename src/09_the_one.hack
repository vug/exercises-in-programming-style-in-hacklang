namespace ex09;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use HH;
use U;

class TFTheOne {
  public function __construct(private mixed $value) {}

  public function bind((function(mixed): mixed) $func): TFTheOne {
    $this->value = $func($this->value);
    return $this;
  }

  public function printme(): void {
    \print_r($this->value);
  }
}

function read_file(string $path_to_file): string {
  $text = \file_get_contents($path_to_file);
  return $text;
}

function filter_chars(string $text): string {
  $pattern = re"/[\W_]+/";
  $replaced = Regex\replace($text, $pattern, ' ');
  return $replaced;
}

function normalize(string $text): string {
  $normalized = Str\lowercase($text);
  return $normalized;
}

function scan(string $text): vec<string> {
  $splitted = U\split_python($text);
  return $splitted;
}

function remove_stop_words(vec<string> $words): vec<string> {
  $stops = keyset(Vec\concat(Str\split(\file_get_contents(U\stop_words_file_path), ','), Str\split(U\ascii_lowercase, '')));  
  $filtered = Vec\filter($words, $w ==> !C\contains_key($stops, $w));
  return $filtered;
}

function frequencies(vec<string> $words): dict<string, int> {
  $word_freqs = Dict\count_values($words);
  return $word_freqs;
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  $word_freqs_sorted = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return $word_freqs_sorted;
}

function top25_freqs(dict<string, int> $word_freqs): void {
  foreach(Dict\take($word_freqs, 25) as $word => $cnt) {
    \print_r("{$word} - {$cnt}\n");
  }
}

function main(string $filepath): void {
  $the_one = new TFTheOne($filepath);
  $the_one
    ->bind(HH\fun('ex09\read_file'))
    ->bind(HH\fun('ex09\filter_chars'))
    ->bind(HH\fun('ex09\normalize'))
    ->bind(HH\fun('ex09\scan'))
    ->bind(HH\fun('ex09\remove_stop_words'))
    ->bind(HH\fun('ex09\frequencies'))
    ->bind(HH\fun('ex09\sort'))
    ->bind(HH\fun('ex09\top25_freqs'))
    ->printme();
}
