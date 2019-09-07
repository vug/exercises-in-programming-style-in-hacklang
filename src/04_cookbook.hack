namespace ex04;
use HH\Lib\{Str, Vec, Dict};
use U;

/**
 * Class to simulate global variables via static members. 
 * Hack does not allows top-level commands including global variable assignments.
 */
final class Globals {
  public static Vector<string> $data = Vector {};
  public static Vector<string> $words = Vector {};
  public static Map<string, int> $word_freqs = Map {};
}

/**
 * Read file into a Vector of characters, $data.
 */
function read_file(string $path_to_file): void {
  $text = \file_get_contents($path_to_file);
  $chars = Str\split($text, '');
  Globals::$data->addAll($chars);
}

/**
 * Replace all non-alphanumeric chars in $data with whitespace.
 */
function filter_chars_and_normalize(): void {
  // in-place
  foreach (Globals::$data as $ix => $char) {
    if (!\ctype_alnum($char)) {
      Globals::$data[$ix] = ' ';
    } else {
      Globals::$data[$ix] = Str\lowercase($char);
    }
  }
}

/**
 * Scan $data for words, fill them into $words.
 */
function scan(): void {
  $text = Str\join(Globals::$data, '');
  $text_words = Str\split($text, ' ');
  $text_words = Vec\filter($text_words, $w ==> $w !== '');
  Globals::$words->addAll($text_words);
}

/**
 * Remove stop words from $words
 */
function remove_stop_words(): void {
  $stop_words_text = \file_get_contents(U\stop_words_file_path);
  $stop_words = Set::fromItems(Str\split($stop_words_text, ','));
  $stop_words->addAll(Str\split(U\ascii_lowercase, ''));

  Globals::$words = Globals::$words->filter(
    $word ==> !$stop_words->contains($word),
  );
}

/**
 * Compute word frequencies into $word_freqs.
 */
function frequencies(): void {
  foreach (Globals::$words as $word) {
    if (Globals::$word_freqs->containsKey($word)) {
      Globals::$word_freqs[$word] += 1;
    } else {
      Globals::$word_freqs[$word] = 1;
    }
  }
}

/**
 * Sort $word_freqs by frequency
 */
function sort_freqs(): void {
  $localized =
    Globals::$word_freqs; // localize but keeps reference, to deal with Hack(3050)
  \arsort(inout $localized);
}

function main(string $file): void {
  read_file($file);
  filter_chars_and_normalize();
  scan();
  remove_stop_words();
  frequencies();
  sort_freqs();

  $top_words = Dict\take(Globals::$word_freqs, 25);
  foreach ($top_words as $word => $freq) {
    echo $word." - ".$freq."\n";
  }
}
