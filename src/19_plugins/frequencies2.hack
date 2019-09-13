namespace ex19\plugins\frequencies2;
use HH\Lib\{Dict};

function top25(vec<string> $words): dict<string, int> {
  $word_freqs = Dict\count_values($words);
  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return Dict\take($sorted_freqs, 25);
}
