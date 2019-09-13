namespace ex19\plugins\frequencies1;
use HH\Lib\{C, Dict};

function top25(vec<string> $words): dict<string, int> {
  $word_freqs = dict[];
  foreach ($words as $word) {
    if (C\contains_key($word_freqs, $word)) {
      $word_freqs[$word] += 1;
    } else {
      $word_freqs[$word] = 1;
    }
  }
  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  $top_25 = dict[];
  foreach ($sorted_freqs as $word => $cnt) {
    if (C\count($top_25) >= 25) {
      break;
    }
    $top_25[$word] = $cnt;
  }
  return $top_25;
}
