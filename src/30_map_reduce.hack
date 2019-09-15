namespace ex30;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function stream_partitions(
  string $filepath,
  int $num_lines,
): \Generator<int, string, void> {
  $file = \fopen($filepath, 'rb');
  $partition = vec[];
  while ($line = \fgets($file)) {
    $partition[] = TypeAssert\string($line) |> Str\trim_right($$);
    if (C\count($partition) === $num_lines) {
      yield Str\join($partition, "\n");
      $partition = vec[];
    }
  }
  if (C\count($partition) > 0) {
    yield Str\join($partition, "\n");
  }
  \fclose($file);
}

function split_words(string $text): vec<(string, int)> {
  $scan = (string $text): vec<string> ==> {
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $lowered = Str\lowercase($replaced);
    $splitted = U\split_python($lowered);
    return $splitted;
  };
  $remove_stop_words = (vec<string> $words): vec<string> ==> {
    $stop_words = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
    $filtered = Vec\filter(
      $words,
      $word ==> !C\contains_key($stop_words, $word),
    );
    return $filtered;
  };

  $non_stop_words = $text |> $scan($$) |> $remove_stop_words($$);
  $result = Vec\map($non_stop_words, $w ==> tuple($w, 1));

  return $result;
}

function count_words(
  vec<(string, int)> $pairs1,
  vec<(string, int)> $pairs2,
): vec<(string, int)> {
  $word_freqs = dict[];
  $add_word_counts = (
    dict<string, int> $word_freqs,
    vec<(string, int)> $pairs,
  ): dict<string, int> ==> {
    foreach ($pairs as list($word, $cnt)) {
      if (C\contains_key($word_freqs, $word)) {
        $word_freqs[$word] += $cnt;
      } else {
        $word_freqs[$word] = $cnt;
      }
    }
    return $word_freqs;
  };

  $word_freqs = $add_word_counts($word_freqs, $pairs1);
  $word_freqs = $add_word_counts($word_freqs, $pairs2);
  return Vec\map_with_key($word_freqs, ($word, $cnt) ==> tuple($word, $cnt));
}

function sort(inout vec<(string, int)> $pairs): void {
  \usort(inout $pairs, ($p1, $p2) ==> $p2[1] - $p1[1]);
}

function main(string $filepath): void {
  $pair_lists = Vec\map(
    stream_partitions($filepath, 200),
    $p ==> split_words($p),
  );
  $word_freq_pairs = C\reduce($pair_lists, HH\fun('ex30\count_words'), vec[]);
  sort(inout $word_freq_pairs);
  foreach (Vec\take($word_freq_pairs, 25) as list($word, $cnt)) {
    \print_r("{$word} - {$cnt}\n");
  }
}
