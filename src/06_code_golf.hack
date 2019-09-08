namespace ex06;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use U;

function main(string $filepath): void {
  $stops = keyset(Vec\concat(Str\split(\file_get_contents(U\stop_words_file_path), ','), Str\split(U\ascii_lowercase, '')));
  $words = Vec\map(Vec\filter(Regex\split(\file_get_contents($filepath), re"/[^a-zA-Z]/"), $w ==> $w !== '' && !C\contains_key($stops, Str\lowercase($w))), $w ==> Str\lowercase($w));
  $word_counts_sorted = Dict\sort_by(Dict\count_values($words), $cnt ==> -$cnt);
  foreach (Dict\take($word_counts_sorted, 25) as $word => $cnt) {
    \print_r("{$word} - {$cnt}\n");
  }  
}