namespace ex24;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

// Poor man's closure detection
function is_closure(mixed $arg): bool {
  try {
    $rf = new \ReflectionFunction($arg);
    return $rf->isClosure();
  } catch (\Exception $_) {
    return false;
  }
}

class TFQuarantine {
  private vec<(function(mixed...): mixed)> $funcs = vec[];

  public function bind((function(mixed...): mixed) $func): this {
    $this->funcs[] = $func;
    return $this;
  }

  public function execute(): mixed {
    $guard_callable = (mixed $v) ==> {
      if (is_closure($v)) {
        // TypeAssert\matches<(function(mixed...): mixed)>($v);
        /* HH_FIXME[4009] Couldn't type cast $v into a function */
        return $v();
      } else {
        return $v;
      }
    };

    $value = () ==> null;
    foreach ($this->funcs as $func) {
      $value = $func($guard_callable($value));
    }
    return $guard_callable($value);
  }
}

class Globals {
  public static string $file_path = "";
}

// IO functions 
function get_input(mixed $_): (function(): string) {
  $func = () ==> Globals::$file_path;
  return $func;
}

function extract_words(string $filepath): (function(): vec<string>) {
  $func = () ==> {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $lowered = Str\lowercase($replaced);
    $splitted = U\split_python($lowered);
    return $splitted;
  };
  return $func;
}

function remove_stop_words(vec<string> $words): (function(): vec<string>) {
  $func = () ==> {
    $filepath = U\stop_words_file_path;
    $text = \file_get_contents($filepath);
    $stop_words = keyset(
      Vec\concat(Str\split($text, ','), Str\split(U\ascii_lowercase, '')),
    );
    return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
  };
  return $func;
}

function print_result(string $result): (function(): mixed) {
  $func = () ==> {
    \print_r($result);
    return null;
  };
  return $func;
}

// 1st order functions
function frequencies(vec<string> $words): dict<string, int> {
  return Dict\count_values($words);
}

function sort(dict<string, int> $word_freqs): dict<string, int> {
  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return $sorted_freqs;
}

function top25_freqs(dict<string, int> $word_freqs): string {
  $lines = vec[];
  foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
    $lines[] = "{$word} - {$cnt}";
  }
  return Str\join($lines, "\n")."\n";
}

function main(string $input): void {
  try {
    // Trick to make get_input reach CLI argument without having function parameters
    Globals::$file_path = $input;

    $q = (new TFQuarantine())
      ->bind(HH\fun('ex24\get_input')) // (...$_) ==> get_input(null) works too
      ->bind(HH\fun('ex24\extract_words'))
      ->bind(HH\fun('ex24\remove_stop_words'))
      ->bind(HH\fun('ex24\frequencies'))
      ->bind(HH\fun('ex24\sort'))
      ->bind(HH\fun('ex24\top25_freqs'))
      ->bind(HH\fun('ex24\print_result'))
      ->execute();
  } catch (\Exception $ex) {
    \print_r($ex->getMessage());
  }
}
