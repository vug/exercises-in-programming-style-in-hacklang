namespace ex10;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use HH;
use U;

abstract class TFExercise {
  public function info(): string {
    return __CLASS__;
  }
}

final class DataStorageManager extends TFExercise {
  private string $data;

  public function __construct(string $filepath): void {
    $text = \file_get_contents($filepath);
    $this->data = Regex\replace($text, re"/[\W_]+/", ' ');
    $this->data = Str\lowercase($this->data);
  }

  public function words(): vec<string> {
    return U\split_python($this->data);
  }

  public function info(): string {
    $rp = new \ReflectionProperty(self::class, "data");
    return parent::info().
      ": My major data structure type is a {$rp->getTypeText()}.\n";
  }
}

final class StopWordManager extends TFExercise {
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

  public function info(): string {
    $rp = new \ReflectionProperty(self::class, "stopWords");
    return parent::info().
      ": My major data structure type is a {$rp->getTypeText()}.\n";
  }
}

final class WordFrequencyManager extends TFExercise {
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

  public function info(): string {
    $rp = new \ReflectionProperty(self::class, "wordFreqs");
    return parent::info().
      ": My major data structure type is a {$rp->getTypeText()}.\n";
  }
}

class WordFrequencyController extends TFExercise {
  private DataStorageManager $dataStorageManager;
  private StopWordManager $stopWordManager;
  private WordFrequencyManager $wordFrequencyManager;

  public function __construct(string $filepath): void {
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
