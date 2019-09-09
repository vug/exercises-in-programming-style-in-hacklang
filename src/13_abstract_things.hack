namespace ex13;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

// Abstract Things
interface IDataStorage {
  public function words(): vec<string>;
}

interface IStopWordFilter {
  public function is_stop_word(string $word): bool;
}

interface IWordFrequencyCounter {
  public function increment_count(string $word): void;
  public function sorted(): dict<string, int>;
}

// Concrete Things
class DataStorageManager implements IDataStorage {
  private vec<string> $data;

  public function __construct(string $filepath) {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $lowered = Str\lowercase($replaced);
    $splitted = U\split_python($lowered);
    $this->data = $splitted;
  }

  public function words(): vec<string> {
    return $this->data;
  }
}

class StopWordManager implements IStopWordFilter {
  private keyset<string> $stopWords;

  public function __construct(): void {
    $this->stopWords = keyset(Vec\concat(
      Str\split(\file_get_contents(U\stop_words_file_path), ','),
      Str\split(U\ascii_lowercase, ''),
    ));
  }

  public function is_stop_word(string $word): bool {
    return C\contains_key($this->stopWords, $word);
  }
}

class WordFrequencyManager implements IWordFrequencyCounter {
  private dict<string, int> $wordFreqs;

  public function __construct(): void {
    $this->wordFreqs = dict[];
  }

  public function increment_count(string $word): void {
    if (C\contains_key($this->wordFreqs, $word)) {
      $this->wordFreqs[$word] += 1;
    } else {
      $this->wordFreqs[$word] = 1;
    }
  }

  public function sorted(): dict<string, int> {
    return Dict\sort_by($this->wordFreqs, $cnt ==> -$cnt);
  }
}


class WordFrequencyController {
  private DataStorageManager $dataStorageManager;
  private StopWordManager $stopWordManager;
  private WordFrequencyManager $wordFrequencyManager;

  public function __construct(string $filepath) {
    $this->dataStorageManager = new DataStorageManager($filepath);
    $this->stopWordManager = new StopWordManager();
    $this->wordFrequencyManager = new WordFrequencyManager();
  }

  public function run(): void {
    foreach ($this->dataStorageManager->words() as $word) {
      if (!$this->stopWordManager->is_stop_word($word)) {
        $this->wordFrequencyManager->increment_count($word);
      }
    }

    $word_freqs = $this->wordFrequencyManager->sorted();
    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  }
}

function main(string $filepath): void {
  (new WordFrequencyController($filepath))->run();
}
