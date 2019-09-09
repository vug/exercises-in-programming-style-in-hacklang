namespace ex12;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;


function extract_words(Map<string, mixed> $obj, string $filepath): void {
  $text = \file_get_contents($filepath);
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowercased = Str\lowercase($replaced);
  $splitted = U\split_python($lowercased);

  $data = TypeAssert\matches<Vector<string>>($obj["data"]);
  $data->addAll($splitted);
}

function load_stop_words(Map<string, mixed> $obj): void {
  $loaded_stops = keyset(Vec\concat(
    Str\split(\file_get_contents(U\stop_words_file_path), ','),
    Str\split(U\ascii_lowercase, ''),
  ));
  $stop_words = TypeAssert\matches<Set<string>>($obj["stop_words"]);
  $stop_words->addAll($loaded_stops);
}

function increment_count(Map<string, mixed> $obj, string $word): void {
  $freqs = TypeAssert\matches<Map<string, int>>($obj["freqs"]);
  if ($freqs->containsKey($word)) {
    $freqs[$word] += 1;
  } else {
    $freqs[$word] = 1;
  }
}

function main(string $filepath): void {
  try { // TypeAssert exceptions were not printed by themselves. Had to catch them.
    $data_storage_obj = Map<string, mixed> {};
    $data_storage_obj["data"] = Vector<string> {};
    $data_storage_obj["init"] = (string $filepath) ==>
      extract_words($data_storage_obj, $filepath);
    $data_storage_obj["words"] = () ==> $data_storage_obj["data"];
    // TypeAssert\matches<TDataStorage>($data_storage_obj);
    // type TDataStorage = shape("data" => Vector<string>, "init" => (function(string): void));
    /* Above attempt to type casting $data_storage_obj give below error because OF_FUNCTION type is not handled by TypeAssert yet. :-(      
     * Typing[4305] Invalid reified hint
     * This is a function type, it cannot be used as a reified type argument
     */

    $stop_words_obj = Map<string, mixed> {};
    $stop_words_obj["stop_words"] = Set<string> {};
    $stop_words_obj["init"] = () ==> load_stop_words($stop_words_obj);
    $stop_words_obj["is_stop_word"] = (string $word) ==> TypeAssert\matches<
      Set<string>,
    >($stop_words_obj["stop_words"])->contains($word);

    $word_freqs_obj = Map<string, mixed> {};
    $word_freqs_obj["freqs"] = Map<string, int> {};
    $word_freqs_obj["increment_count"] = (string $word) ==>
      increment_count($word_freqs_obj, $word);
    $word_freqs_obj["sorted"] = () ==> {
      $localized = TypeAssert\matches<Map<string, int>>(
        $word_freqs_obj["freqs"],
      );
      \arsort(inout $localized);
      return $localized;
    };

    /* HH_FIXME[4009] */ // Error 4009: This call is invalid, this is not a function, it is a mixed value
    $data_storage_obj["init"]($filepath);
    /* HH_FIXME[4009] */
    $stop_words_obj["init"]();

    /* HH_FIXME[4009] */
    foreach ($data_storage_obj["words"]() as $word) {
      /* HH_FIXME[4009] */
      if (!$stop_words_obj["is_stop_word"]($word)) {
        /* HH_FIXME[4009] */
        $word_freqs_obj["increment_count"]($word);
      }
    }
    /* HH_FIXME[4009] */
    $word_freqs = $word_freqs_obj["sorted"]();

    foreach (Dict\take($word_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
