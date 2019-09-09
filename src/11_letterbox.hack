namespace ex11;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeSpec};
use HH;
use U;

enum Message: string as string {
  init = "init";
  increment_count = "increment_count";
  is_stop_word = "is_stop_word";
  run = "run";
  sorted = "sorted";
  words = "words";
}


final class DataStorageManager {
  private string $data = '';

  public function dispatch(Message $message, mixed $argument = null): mixed {
    switch ($message) {
      case Message::init:
        $filepath = TypeAssert\string($argument);
        return $this->init($filepath);
        break;
      case Message::words:
        return $this->words();
        break;
      default:
        throw new \Exception("Message not understood ".$message);
    }
  }

  private function init(string $filepath): void {
    $text = \file_get_contents($filepath);
    $this->data = Regex\replace($text, re"/[\W_]+/", ' ');
    $this->data = Str\lowercase($this->data);
  }

  private function words(): vec<string> {
    return U\split_python($this->data);
  }
}


final class StopWordsManager {
  private keyset<string> $stopWords = keyset[];

  public function dispatch(Message $message, mixed $argument = null): mixed {
    switch ($message) {
      case Message::init:
        return $this->init();
        break;
      case Message::is_stop_word:
        $word = TypeAssert\string($argument);
        return $this->is_stop_word($word);
        break;
      default:
        throw new \Exception("Message not understood ".$message);
    }
  }

  public function init(): void {
    $this->stopWords = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
  }

  public function is_stop_word(string $word): bool {
    return C\contains_key($this->stopWords, $word);
  }
}


final class WordFrequencyManager {
  private dict<string, int> $wordFreqs;

  public function __construct(): void {
    $this->wordFreqs = dict[];
  }

  public function dispatch(Message $message, mixed $argument = null): mixed {
    switch ($message) {
      case Message::increment_count:
        $word = TypeAssert\string($argument);
        return $this->increment_count($word);
        break;
      case Message::sorted:
        return $this->sorted();
        break;
      default:
        throw new \Exception("Message not understood ".$message);
    }
  }

  private function increment_count(string $word): void {
    if (C\contains_key($this->wordFreqs, $word)) {
      $this->wordFreqs[$word] += 1;
    } else {
      $this->wordFreqs[$word] = 1;
    }
  }

  private function sorted(): dict<string, int> {
    return Dict\sort_by($this->wordFreqs, $cnt ==> -$cnt);
  }
}


final class WordFrequencyController {
  private DataStorageManager $dataStorageManager;
  private StopWordsManager $stopWordsManager;
  private WordFrequencyManager $wordFrequencyManager;

  public function __construct(): void {
    $this->dataStorageManager = new DataStorageManager();
    $this->stopWordsManager = new StopWordsManager();
    $this->wordFrequencyManager = new WordFrequencyManager();
  }

  public function dispatch(Message $message, mixed $argument = null): mixed {
    switch ($message) {
      case Message::init:
        $filepath = TypeAssert\string($argument);
        return $this->init($filepath);
        break;
      case Message::run:
        return $this->run();
        break;
      default:
        throw new \Exception("Message not understood ".$message);
    }
  }

  private function init(string $filepath): void {
    $this->dataStorageManager
      ->dispatch(Message::init, $filepath);
    $this->stopWordsManager->dispatch(Message::init);
  }

  private function run(): void {
    $words = $this->dataStorageManager
      ->dispatch(Message::words);
    $words = TypeSpec\vec(TypeSpec\string())->assertType($words);
    foreach ($words as $word) {
      $is_stop_word = $this->stopWordsManager
        ->dispatch(Message::is_stop_word, $word);
      $is_stop_word = TypeAssert\bool($is_stop_word);
      if (!$is_stop_word) {
        $this->wordFrequencyManager->dispatch(Message::increment_count, $word);
      }
    }

    $word_freqs = $this->wordFrequencyManager
      ->dispatch(Message::sorted);
    $word_freqs = TypeSpec\dict(TypeSpec\string(), TypeSpec\int())->assertType(
      $word_freqs,
    );
    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}


function main(string $filepath): void {
  try { // TypeAssert exceptions were not printed by themselves. Had to catch them.
    $wf_controller = new WordFrequencyController();
    $wf_controller->dispatch(Message::init, $filepath);
    $wf_controller->dispatch(Message::run);
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
