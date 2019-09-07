/**
 * Utility functions to resemble Python's style of 
*/
namespace U;
use HH\Lib\{Regex, Str, Vec};

const string stop_words_file_path = "texts/stop_words.txt";

const string ascii_lowercase = "abcdefghijklmnopqrstuvwxyz";

/**
 * Split like in Python. If second argument is not given return stripped words only. If given, regular split.
 */
function split_python(string $text, string $token = '__ALL_WHITESPACES__'): vec<string> {
  if ($token === '__ALL_WHITESPACES__') {
    $pattern = re"/[\W_]+/";
    $replaced = Regex\replace($text, $pattern, ' ');    
    $splitted = Str\split($replaced, ' ');
    $result = Vec\filter($splitted, $s ==> $s !== '');
  }
  else {
    $result = Str\split($text, $token);
  }
  
  return $result;
}
