namespace ex03;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function main(string $filepath): void {
  $word_freqs = vec[];
  $stop_words = Keyset\union(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
    Str\split(U\ascii_lowercase, ''),
  );

  foreach (Str\split(\file_get_contents($filepath), "\n") as $line) {
    $start_char = null;
    $i = 0;
    foreach (Str\split($line, '') as $char) {
      if ($start_char === null) {
        if (\ctype_alnum($char)) { // found word start
          $start_char = $i;
        }
      } else {
        if (!\ctype_alnum($char)) { // found word end
          $has_word_seen = false;
          $word = Str\lowercase(
            Str\slice($line, $start_char, $i - $start_char),
          );
          if (!C\contains_key($stop_words, $word)) { // ignore stop words

            for ($pair_ix = 0; $pair_ix < C\count($word_freqs); $pair_ix++) {
              if ($word === $word_freqs[$pair_ix][0]) {
                $word_freqs[$pair_ix][1] += 1;
                $has_word_seen = true;
                break;
              }
            }
            if (!$has_word_seen) {
              $word_freqs[] = tuple($word, 1);
            } elseif (C\count($word_freqs) > 1) { // may need to reorder
              for ($j = C\count($word_freqs) - 1; $j >= 0; $j--) {
                if ($word_freqs[$pair_ix][1] > $word_freqs[$j][1]) {
                  $tmp = $word_freqs[$j];
                  $word_freqs[$j] = $word_freqs[$pair_ix];
                  $word_freqs[$pair_ix] = $tmp;
                  $pair_ix = $j;
                }
              }
            }
          }
          $start_char = null;
        }
      }
      $i++;
    }
  }

  foreach (Vec\take($word_freqs, 25) as $tf) {
    \print_r("{$tf[0]} - {$tf[1]}\n");
  }
}
