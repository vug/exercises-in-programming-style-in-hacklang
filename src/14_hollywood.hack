namespace ex14;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

class WordFrequencyFramework {
  private vec<(function(mixed...): void)> $loadEventHandlers = vec[];
  private vec<(function(mixed...): void)> $doWorkEventHandlers = vec[];
  private vec<(function(mixed...): void)> $endEventHandlers = vec[];

  public function register_for_load_event(
    (function(mixed...): void) $handler,
  ): void {
    $this->loadEventHandlers[] = $handler;
  }

  public function register_for_dowork_event(
    (function(mixed...): void) $handler,
  ): void {
    $this->doWorkEventHandlers[] = $handler;
  }

  public function register_for_end_event(
    (function(mixed...): void) $handler,
  ): void {
    $this->endEventHandlers[] = $handler;
  }

  public function run(string $filepath): void {
    foreach ($this->loadEventHandlers as $handler) {
      $handler($filepath);
    }
    foreach ($this->doWorkEventHandlers as $handler) {
      $handler();
    }
    foreach ($this->endEventHandlers as $handler) {
      $handler();
    }
  }
}

class StopWordFilter {
  public keyset<string> $stopWords = keyset[];

  public function __construct(WordFrequencyFramework $wf_app): void {
    $wf_app->register_for_load_event((mixed ...$_) ==> $this->on_load());
  }

  private function on_load(): void {
    $this->stopWords = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
  }

  // this not being registered breaks the style
  public function is_stop_word(string $word): bool {
    return C\contains_key($this->stopWords, $word);
  }
}

class DataStorage {
  public string $data = '';
  private StopWordFilter $stopWordFilter;
  private vec<(function(mixed...): void)> $wordEventHandler = vec[];

  public function __construct(
    WordFrequencyFramework $wf_app,
    StopWordFilter $stopWordFilter,
  ) {
    $this->stopWordFilter = $stopWordFilter;
    $wf_app->register_for_load_event(
      (mixed ...$args) ==> {
        $filepath = TypeAssert\string($args[0]);
        $this->on_load($filepath);
      },
    );
    $wf_app->register_for_dowork_event(
      (mixed ...$_) ==> $this->produce_words(),
    );
  }

  private function on_load(string $filepath): void {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $this->data = Str\lowercase($replaced);
  }

  private function produce_words(): void {
    foreach (U\split_python($this->data) as $word) {
      if (!$this->stopWordFilter->is_stop_word($word)) {
        foreach ($this->wordEventHandler as $handler) {
          $handler($word);
        }
      }
    }
  }

  public function register_for_word_event(
    (function(mixed...): void) $handler,
  ): void {
    $this->wordEventHandler[] = $handler;
  }
}

class WordFrequencyCounter {
  private dict<string, int> $wordFreqs = dict[];

  public function __construct(
    WordFrequencyFramework $wf_app,
    DataStorage $data_storage,
  ): void {
    $data_storage->register_for_word_event((mixed ...$args) ==> {
      $word = TypeAssert\string($args[0]);
      $this->increment_count($word);
    });
    $wf_app->register_for_end_event((mixed ...$_) ==> $this->print_freqs());
  }

  private function increment_count(string $word): void {
    if (C\contains_key($this->wordFreqs, $word)) {
      $this->wordFreqs[$word] += 1;
    } else {
      $this->wordFreqs[$word] = 1;
    }
  }

  private function print_freqs(): void {
    $word_freqs = Dict\sort_by($this->wordFreqs, $cnt ==> -$cnt);
    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}

function main(string $filepath): void {
  $wf_app = new WordFrequencyFramework();
  $stop_word_filter = new StopWordFilter($wf_app);
  $data_storage = new DataStorage($wf_app, $stop_word_filter);
  $word_freq_counter = new WordFrequencyCounter($wf_app, $data_storage);

  $wf_app->run($filepath);
}
