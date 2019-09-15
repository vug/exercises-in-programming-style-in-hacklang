namespace ex27;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function stream_file(string $filepath): \Generator<int, string, void> {
  $file = \fopen($filepath, 'rb');
  while ($line = \fgets($file)) {
    $line = TypeAssert\string($line);
    yield Str\trim_right($line);
  }
  \fclose($file);
}

function stream_characters(
  \Generator<int, string, void> $line_stream,
): \Generator<int, string, void> {
  foreach ($line_stream as $line) {
    foreach (Str\split($line, '') as $char) {
      yield $char;
    }
  }
}

function stream_words(
  \Generator<int, string, void> $char_stream,
): \Generator<int, string, void> {
  $is_start = true;
  $word = "";
  foreach ($char_stream as $char) {
    if ($is_start) {
      $word = "";
      if (\ctype_alnum($char)) {
        $word = Str\lowercase($char);
        $is_start = false;
      }
    } else {
      if (\ctype_alnum($char)) {
        $word .= Str\lowercase($char);
      } else {
        $is_start = true;
        yield $word;
      }
    }
  }
}

function filter_stop_words(
  \Generator<int, string, void> $word_stream,
): \Generator<int, string, void> {
  $stop_words = keyset(Vec\concat(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
    Str\split(U\ascii_lowercase, ''),
  ));
  foreach ($word_stream as $word) {
    if (!C\contains_key($stop_words, $word)) {
      yield $word;
    }
  }
}

function online_count_and_sort(
  \Generator<int, string, void> $word_stream,
): \Generator<int, dict<string, int>, void> {
  $word_freqs = dict[];
  $i = 1;
  foreach ($word_stream as $word) {
    $word_freqs[$word] = C\contains_key($word_freqs, $word)
      ? $word_freqs[$word] + 1
      : 1;
    if ($i % 5000 === 0) {
      yield Dict\sort_by($word_freqs, $cnt ==> -$cnt);
    }
    $i += 1;
  }
  yield Dict\sort_by($word_freqs, $cnt ==> -$cnt);
}

function print_top25(
  \Generator<int, dict<string, int>, void> $word_freqs_stream,
): void {
  foreach ($word_freqs_stream as $word_freqs) {
    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}

function main(string $filepath): void {
  $word_freqs_stream = $filepath
    |> stream_file($$)
    |> stream_characters($$)
    |> stream_words($$)
    |> filter_stop_words($$)
    |> online_count_and_sort($$);
  foreach ($word_freqs_stream as $word_freqs) {
    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}

function p(mixed ...$args): void {
  foreach ($args as $arg) {
    \print_r($arg);
    \print_r(', ');
  }
}

function pn(mixed ...$args): void {
  foreach ($args as $arg) {
    \print_r($arg);
    \print_r("\n");
  }
}
