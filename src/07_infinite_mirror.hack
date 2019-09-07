namespace ex07;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use U;

const int RECURSION_LIMIT = 1750;

function count(
  vec<string> $word_list,
  keyset<string> $stop_words,
  inout dict<string, int> $word_freqs,
): void {
  if (C\count($word_list) === 0) {
    return;
  } else {
    $word = $word_list[0];
    if (!C\contains($stop_words, $word)) {
      if (C\contains_key($word_freqs, $word)) {
        $word_freqs[$word] += 1;
      } else {
        $word_freqs[$word] = 1;
      }
    }
    count(Vec\slice($word_list, 1), $stop_words, inout $word_freqs);
  }
}

function print_top25(dict<string, int> $word_freqs): void {
  $top25 = Dict\take($word_freqs, 25);
  foreach ($top25 as $word => $freq) {
    \print_r($word." - ".$freq."\n");
  }
}

function main(string $file): void {
  $normalized = Str\lowercase(
    Regex\replace(\file_get_contents($file), re"/[\W_]+/", ' '),
  );
  $words = Vec\filter(Str\split($normalized, ' '), $w ==> $w !== '');
  $stop_words = Keyset\union(
    keyset(Str\split(\file_get_contents(U\stop_words_file_path), ',')),
    keyset(Str\split(U\ascii_lowercase, '')),
  );

  $word_freqs = dict[];
  // To prevent stack overflow reduce the recursion depth and do recursion on smaller chunks.
  for ($i = 0; $i < C\count($words); $i += RECURSION_LIMIT) {
    count(
      Vec\slice($words, $i, RECURSION_LIMIT),
      $stop_words,
      inout $word_freqs,
    );
  }
  $sorted = Dict\sort_by($word_freqs, $v ==> -$v);
  print_top25($sorted);
}
