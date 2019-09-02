require_once(__DIR__.'/../vendor/autoload.hack');

/**
 * Class to simulate global variables. Hack does not allows top-level commands.
 * Hence had to put variable accessed by every function into a class.
 */
final class Globals {
    public static Vector<string> $data = Vector {};
    public static Vector<string> $words = Vector {};
    // public static Map<string, int> $word_freqs = Map {};  // for in-place sorting
    public static dict<string, int> $word_freqs = dict[];
}

/**
 * Read file into a vec of characters.
 */
function read_file(string $path_to_file): void {
    $text = file_get_contents($path_to_file);
    $chars = HH\Lib\Str\split($text, '');
    Globals::$data->addAll($chars);
}

/**
 * Replaces all non-alphanumeric chars in data with whitespace.
 */
function filter_chars_and_normalize(): void {
    // in-place
    foreach (Globals::$data as $ix => $char) {
        if (!ctype_alnum($char)) {
            Globals::$data[$ix] = ' ';
        } else {
            Globals::$data[$ix] = HH\Lib\Str\lowercase($char);
        }
    }
    // out-of-place
    // Globals::$data = Globals::$data->map($ch ==> ctype_alnum($ch) ? $ch : ' ');
}

/**
 * Scans data for words, filling the global variable $words.
 */
function scan(): void {
    $text = HH\Lib\Str\join(Globals::$data, '');
    $text_words = HH\Lib\Str\split($text, ' ');
    $text_words = HH\Lib\Vec\filter($text_words, $w ==> $w !== '');
    Globals::$words->addAll($text_words);
}

function remove_stop_words(): void {
    $stop_words_text = file_get_contents("texts/stop_words.txt");
    $stop_words = Set::fromItems(HH\Lib\Str\split($stop_words_text, ','));

    $lowercase_chars_text = "abcdefghijklmnopqrstuvwxyz";
    $stop_words->addAll(HH\Lib\Str\split($lowercase_chars_text, ''));

    Globals::$words = Globals::$words->filter($word ==> !$stop_words->contains($word));
}

/**
 * Creates a list of pairs associating words with frequencies.
 */
function frequencies(): void {
    foreach (Globals::$words as $word) {
        // if (Globals::$word_freqs->containsKey($word)) {  // in-place version
        if (HH\Lib\C\contains_key(Globals::$word_freqs, $word)) {
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
    // in-place sort. But only works on local variables.
    // arsort(inout Globals::$word_freqs);  // in-place sort.
    Globals::$word_freqs = HH\Lib\Dict\sort(
        Globals::$word_freqs,
        ($n, $m) ==> $m - $n,
    );
}

<<__EntryPoint>>
function main_05_cookbook(string $file): noreturn {
    \Facebook\AutoloadMap\initialize();

    read_file($file);
    filter_chars_and_normalize();
    scan();
    remove_stop_words();
    frequencies();
    sort_freqs();

    $top_words = HH\Lib\Dict\take(Globals::$word_freqs, 25);
    foreach ($top_words as $word => $freq) {
        echo $word." - ".$freq."\n";
    }

    exit(0);
}
