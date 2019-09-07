namespace ex08;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace HH;
use U;

class Functions {
  public static function read_file(
    string $filepath,
    (function(mixed, mixed): void) $func,
  ): void {
    $text = \file_get_contents($filepath);
    $func($text, HH\class_meth(Functions::class, 'normalize'));
  }

  public static function filter_chars(
    string $text,
    (function(mixed, mixed): void) $func,
  ): void {
    $pattern = re"/[\W_]+/";
    $replaced = Regex\replace($text, $pattern, ' ');
    $func($replaced, HH\class_meth(Functions::class, 'scan'));
  }

  public static function normalize(
    string $text,
    (function(mixed, mixed): void) $func,
  ): void {
    $lowered = Str\lowercase($text);
    $func($lowered, HH\class_meth(Functions::class, 'remove_stop_words'));
  }

  public static function scan(
    string $text,
    (function(mixed, mixed): void) $func,
  ): void {
    $splitted = U\split_python($text);
    $func($splitted, HH\class_meth(Functions::class, 'frequencies'));
  }

  public static function remove_stop_words(
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
    $func($filtered, HH\class_meth(Functions::class, 'sort'));
  }

  public static function frequencies(
    vec<string> $words,
    (function(mixed, mixed): void) $func,
  ): void {
    $word_freqs = Dict\count_values($words);
    $func($word_freqs, HH\class_meth(Functions::class, 'print_text'));
  }

  public static function sort(
    dict<string, int> $word_freqs,
    (function(mixed, mixed): void) $func,
  ): void {
    $word_freqs_sorted = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
    $func($word_freqs_sorted, HH\class_meth(Functions::class, 'no_op'));
  }

  public static function print_text(
    dict<string, int> $word_freqs,
    (function(mixed, mixed): void) $func,
  ): void {
    foreach (Dict\take($word_freqs, 25) as $word => $freq) {
      \print_r($word." - ".$freq."\n");
    }
    $func(null, null);
  }

  public static function no_op(null $_, null $_): void {}
}


function main(string $filepath): void {
  Functions::read_file(
    $filepath,
    HH\class_meth(Functions::class, 'filter_chars'),
  );
}
