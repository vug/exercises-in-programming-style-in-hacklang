require_once(__DIR__.'/../vendor/autoload.hack');

final class Globals {
    public static vec<string> $data = vec[];
    public static vec<string> $words = vec[];
    public static dict<string, int> $word_freqs = dict[];
}

/**
 * Read file into a vec of characters.
 */
function read_file(string $path_to_file): void {
    $text = file_get_contents($path_to_file);    
    $chars = HH\Lib\Str\split($text, '');
    Globals::$data = HH\Lib\Vec\concat(Globals::$data, $chars);
}

/**
 * Replaces all non-alphanumeric chars in data with whitespace.
 */
function filter_chars_and_normalize(): void {
    // in-place
    foreach(Globals::$data as $ix => $char) {
        if (!ctype_alnum($char)) {
            Globals::$data[$ix] = ' ';
        }
        else {
            Globals::$data[$ix] = HH\Lib\Str\lowercase($char);
        }
    }
    // replace
    // Globals::$data = HH\Lib\Vec\map(Globals::$data, $ch ==> ctype_alnum($ch) ? $ch : ' ');
}

/**
 * Scans data for words, filling the global variable $words.
 */
function scan(): void {
    $text = HH\Lib\Str\join(Globals::$data, '');
    $words = HH\Lib\Str\split($text, ' ');
    $words = HH\Lib\Vec\filter($words, $w ==> $w !== '');
    Globals::$words = HH\Lib\Vec\concat(Globals::$words, $words);
}

function remove_stop_words(): void {
    $text = file_get_contents("src/stop_words.txt");
    $lowercase_chars = "abcdefghijklmnopqrstuvwxyz";
    $stop_words_vec = HH\Lib\Vec\concat(
        HH\Lib\Str\split($text, ','),
        HH\Lib\Str\split($lowercase_chars, '')
    );
    $stop_words = keyset[];
    foreach($stop_words_vec as $word) {
        $stop_words[] = $word;
    }
    
    Globals::$words = HH\Lib\Vec\filter(
        Globals::$words, 
        $word ==> !HH\Lib\C\contains_key($stop_words, $word)
    );
}

/**
 * Creates a list of pairs associating words with frequencies.
 */
function frequencies(): void {
    foreach(Globals::$words as $word) {
        if (HH\Lib\C\contains_key(Globals::$word_freqs, $word)) {
            Globals::$word_freqs[$word] += 1;
        }
        else {
            Globals::$word_freqs[$word] = 1;
        }
    }
}

/**
 * Sort $word_freqs by frequency
 */
function sort_freqs(): void {
    Globals::$word_freqs = HH\Lib\Dict\sort(Globals::$word_freqs, ($n, $m) ==> $m - $n);
}

<<__EntryPoint>>
function main_05_cookbook(): noreturn {
    \Facebook\AutoloadMap\initialize();

    $options = getopt("", vec["text:"]);    
    $file = HH\Lib\C\contains_key($options, "text") ? $options["text"] : "src/pride-and-prejudice.txt";
    // print_r(var_dump($file));
    read_file($file);
    // print_r(Globals::$data);
    filter_chars_and_normalize();
    // print_r(Globals::$data);
    scan();
    // print_r(Globals::$words);
    remove_stop_words();
    // print_r(Globals::$words);
    frequencies();
    // print_r(Globals::$word_freqs);
    sort_freqs();
    // print_r(Globals::$word_freqs);

    $top_words = HH\Lib\Dict\take(Globals::$word_freqs, 25);
    foreach($top_words as $word => $freq) {
        echo $word . " - " . $freq . "\n";
    }

    exit(0);
}
