namespace ex32;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

final class WordFrequenciesModel {
  public dict<string, int> $word_freqs = dict[];

  public function __construct(string $filepath): void {}

  public function update(string $filepath): void {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $lowered = Str\lowercase($replaced);
    $splitted = U\split_python($lowered);

    $stop_words = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
    $non_stop_words = Vec\filter(
      $splitted,
      $word ==> !C\contains_key($stop_words, $word),
    );
    $this->word_freqs = Dict\count_values($non_stop_words);
  }

}

final class WordFrequenciesView {
  public function __construct(private WordFrequenciesModel $model): void {}

  public function render(): void {
    $sorted_freqs = Dict\sort_by($this->model->word_freqs, $cnt ==> -$cnt);
    foreach (Dict\take($sorted_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}

function get_user_input(): string {
  $file = \fopen('php://stdin', 'r');
  $input = \fgets($file);
  \fclose($file);

  // // other non-functional alternatives
  // $io = HH\Lib\Experimental\IO\request_input();
  // $io = \HH\Lib\_Private\StdioHandle::serverInput();

  // $input = $io->rawReadBlocking(100);
  // $input = await $io->readAsync();  
  return $input;
}

final class WordFreqenciesController {
  public function __construct(
    private WordFrequenciesModel $model,
    private WordFrequenciesView $view,
  ): void {}

  public function run(string $filepath): void {
    // \print_r("Next file: ");
    // $filename = get_user_input();
    $filename = $filepath;
    $this->model->update($filename);
    $this->view->render();
  }
}

async function main(
  string $filepath,
  HH\Lib\Experimental\IO\ReadHandle $stdin,
): Awaitable<void> {
  try {
    $m = new WordFrequenciesModel($filepath);
    $v = new WordFrequenciesView($m);
    $c = new WordFreqenciesController($m, $v);
    $c->run($filepath);
  } catch (\Exception $ex) {
    \print_r($ex->getMessage());
  }
}
