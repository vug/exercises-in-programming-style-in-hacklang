namespace ex26;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function count_items<Titem>(vec<Titem> $container, Titem $item): int {
  return C\count(Vec\filter($container, $x ==> $x === $item));
}

class Spreadsheet {
  const type TColumn =
    shape("data" => vec<mixed>, "formula" => ?(function(): vec<mixed>));

  public dict<string, self::TColumn> $columns;

  public function __construct(): void {
    $this->columns = dict[];
    $this->columns["all_words"] = shape("data" => vec[], "formula" => null);
    $this->columns["stop_words"] = shape("data" => vec[], "formula" => null);
    $this->columns["non_stop_words"] = shape(
      "data" => vec[],
      "formula" => () ==> Vec\map(
        $this->columns["all_words"]['data'],
        $w ==> C\contains($this->columns["stop_words"]['data'], $w) ? '' : $w,
      ),
    );
    $this->columns["unique_words"] = shape(
      "data" => vec[],
      "formula" => () ==> {
        $filtered = Vec\filter(
          $this->columns["non_stop_words"]['data'],
          $w ==> $w != '',
        );
        $filtered = TypeAssert\matches<vec<string>>($filtered);
        return Vec\unique($filtered);
      },
    );
    $this->columns["counts"] = shape(
      "data" => vec[],
      "formula" => () ==> {
        $unique_words = TypeAssert\matches<vec<string>>(
          $this->columns["unique_words"]['data'],
        );
        return Vec\map(
          $unique_words,
          $word ==> count_items($this->columns["all_words"]['data'], $word),
        );
      },
    );
    $this->columns["sorted_counts"] = shape(
      "data" => vec[],
      "formula" => () ==> {
        $unique_words = TypeAssert\matches<vec<string>>(
          $this->columns["unique_words"]['data'],
        );
        $counts = TypeAssert\matches<vec<int>>(
          $this->columns["counts"]['data'],
        );
        $word_freqs = Dict\associate($unique_words, $counts);
        $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
        return Vec\map_with_key(
          $sorted_freqs,
          ($word, $cnt) ==> vec[$word, $cnt],
        );
      },
    );
  }

  public function update(): void {
    foreach ($this->columns as $name => $col) {
      $formula = $col['formula'];
      if ($formula !== null) {
        $this->columns[$name]['data'] = $formula();
      }
    }
  }
}

function main(string $filepath): void {
  try {
    $s = new Spreadsheet();

    $s->columns["stop_words"]['data'] = Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    );
    $s->columns["all_words"]['data'] = Vec\map(
      Regex\every_match(
        Str\lowercase(\file_get_contents($filepath)),
        re"/[a-z]{2,}/",
      ),
      $w ==> $w[0],
    );

    $s->update();
    $sorted_freqs = $s->columns["sorted_counts"]['data'];
    foreach (Vec\take($sorted_freqs, 25) as $pair) {
      $pair = TypeAssert\matches<vec<mixed>>($pair);
      $word = TypeAssert\string($pair[0]);
      $cnt = TypeAssert\int($pair[1]);
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->getMessage());
  }
}
