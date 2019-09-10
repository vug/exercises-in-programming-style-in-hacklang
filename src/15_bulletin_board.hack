namespace ex15;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

class EventManager {
  private dict<string, vec<(function(mixed...): void)>> $subscriptions = dict[];

  public function subscribe(
    string $event_type,
    (function(mixed...): void) $handler,
  ): void {
    if (C\contains_key($this->subscriptions, $event_type)) {
      $this->subscriptions[$event_type][] = $handler;
    } else {
      $this->subscriptions[$event_type] = vec[$handler];
    }
  }

  public function publish(string $event_type, mixed ...$args): void {
    if (C\contains_key($this->subscriptions, $event_type)) {
      foreach ($this->subscriptions[$event_type] as $handler) {
        $handler(...$args); // without ellipsis handlers get an array.
      }
    }
  }
}

class DataStorage {
  private string $data = "";

  public function __construct(private EventManager $event_manager): void {
    $this->event_manager->subscribe(
      "load",
      (mixed ...$args) ==> {
        $filepath = TypeAssert\string($args[0]);
        $this->load($filepath);
      },
    );
    $this->event_manager
      ->subscribe("start", (mixed ...$_) ==> $this->produce_words());
  }

  private function load(string $filepath): void {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $this->data = Str\lowercase($replaced);
  }

  private function produce_words(): void {
    foreach (U\split_python($this->data) as $word) {
      $this->event_manager->publish("word", $word);
    }
    $this->event_manager->publish("eof");
  }
}

class StopWordFilter {
  private keyset<string> $stopWords = keyset[];

  public function __construct(private EventManager $event_manager) {
    $this->event_manager->subscribe("load", (mixed ...$_) ==> $this->load());
    $this->event_manager->subscribe("word", (mixed ...$args) ==> {
      $word = TypeAssert\string($args[0]);
      $this->is_stop_word($word);
    });
  }

  private function load(): void {
    $this->stopWords = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
  }

  private function is_stop_word(string $word): void {
    if (!C\contains_key($this->stopWords, $word)) {
      $this->event_manager->publish("valid_word", $word);
    }
  }
}

class WordFrequencyCounter {
  private dict<string, int> $wordFreqs = dict[];

  public function __construct(private EventManager $event_manager) {
    $this->event_manager->subscribe("valid_word", (mixed ...$args) ==> {
      $word = TypeAssert\string($args[0]);
      $this->increment_count($word);
    });
    $this->event_manager
      ->subscribe("print", (mixed ...$_) ==> $this->print_freqs());
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

class WordFrequencyApplication {
  public function __construct(private EventManager $event_manager) {
    $this->event_manager->subscribe("run", (mixed ...$args) ==> {
      $filepath = TypeAssert\string($args[0]);
      $this->run($filepath);
    });
    $this->event_manager->subscribe("eof", (mixed ...$_) ==> $this->stop());
  }

  private function run(string $filepath): void {
    $this->event_manager->publish("load", $filepath);
    $this->event_manager->publish("start");
  }

  private function stop(): void {
    $this->event_manager->publish("print");
  }
}

function main(string $filepath): void {
  try {
    $em = new EventManager();
    new DataStorage($em);
    new StopWordFilter($em);
    new WordFrequencyCounter($em);
    new WordFrequencyApplication($em);

    $em->publish("run", $filepath);
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
