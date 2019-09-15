namespace ex31;
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

function regroup(
  vec<vec<(string, int)>> $pairs_list,
): dict<string, vec<(string, int)>> {
  $mappings = dict[];
  foreach ($pairs_list as $pairs) {
    foreach ($pairs as $pair) {
      $word = $pair[0];
      if (C\contains_key($mappings, $word)) {
        $mappings[$word][] = $pair;
      } else {
        $mappings[$word] = vec[$pair];
      }
    }
  }
  return $mappings;
}

function count_words((string, vec<(string, int)>) $mapping): (string, int) {
  list($word, $pairs) = $mapping;
  $counts = Vec\map($pairs, $p ==> $p[1]);
  $count = C\reduce($counts, ($x, $y) ==> $x + $y, 0);
  return tuple($word, $count);
}

function sort(inout vec<(string, int)> $pairs): void {
  \usort(inout $pairs, ($p1, $p2) ==> $p2[1] - $p1[1]);
}

function main(string $filepath): void {
  $pairs_list = Vec\map(
    stream_partitions($filepath, 200),
    $p ==> split_words($p),
  );
  $splits_per_word = regroup($pairs_list);
  $word_freq_pairs = Vec\map_with_key(
    $splits_per_word,
    ($word, $pairs) ==> count_words(tuple($word, $pairs)),
  );
  sort(inout $word_freq_pairs);
  foreach (Vec\take($word_freq_pairs, 25) as list($word, $cnt)) {
    \print_r("{$word} - {$cnt}\n");
  }
}
