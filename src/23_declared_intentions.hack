namespace ex23;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

/**
 * Poor man's run-time type checking system.
 * Checks primitives and vecs and dicts of primitives.
 */
function simple_gettype(mixed $var): string {
  $type = \gettype($var);
  if ($type === "vec") {
    $var = TypeAssert\matches<vec<mixed>>($var);
    $item = $var[0];
    $item_type = \gettype($item);
    return "vec<{$item_type}>";
  } elseif ($type === "dict") {
    $var = TypeAssert\matches<dict<mixed, mixed>>($var);
    foreach ($var as $key => $val) {
      $key_type = \gettype($key);
      $val_type = \gettype($val);
      return "dict<{$key_type},$val_type>";
    }
    return $type;
  } else {
    return $type;
  }
}

function accept_types<Treturn>(
  (function(mixed...): Treturn) $func,
  string ...$accepted_types
): (function(mixed...): Treturn) {
  $rf = new \ReflectionFunction($func);
  $num_types = C\count($accepted_types);
  $num_params = C\count($rf->getParameters());
  if ($num_types !== $num_params) {
    throw new \Exception(
      "Parameter count of {$rf->name} ({$num_params}) ".
      "does not match given accepted types count ({$num_types}).",
    );
  }

  $types_wrapper = (mixed ...$args): Treturn ==> {
    // hope gettype stays in Hack.
    $arg_types = Vec\map($args, $arg ==> simple_gettype($arg));

    for ($i = 0; $i < C\count($args); $i++) {
      if ($arg_types[$i] !== $accepted_types[$i]) {
        throw new \Exception(
          "The type of given argument no {$i} of {$rf
            ->name}, {$arg_types[$i]}, ".
          "is different than the accepted type {$accepted_types[$i]}",
        );
      }
    }
    $return_value = $func(...$args);
    return $return_value;
  };
  return $types_wrapper;
}

/* HH_FIXME[4032] */
function extract_words($filepath): mixed {
  $text = @\file_get_contents($filepath); // @ suppresses warning.
  invariant($text is string, "file does not exist.");
  $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
  $lowered = Str\lowercase($replaced);
  $splitted = U\split_python($lowered);
  return $splitted;
}

/* HH_FIXME[4032] */
function remove_stop_words($words): mixed {
  $filepath = U\stop_words_file_path;
  $text = @\file_get_contents($filepath); // @ suppresses warning.
  invariant($text is string, "file does not exist.");
  $stop_words = keyset(
    Vec\concat(Str\split($text, ','), Str\split(U\ascii_lowercase, '')),
  );
  return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
}

/* HH_FIXME[4032] */
function frequencies($words): mixed {
  return Dict\count_values($words);
}

/* HH_FIXME[4032] */
function sort($word_freqs): mixed {
  $sorted_freqs = Dict\sort_by($word_freqs, $cnt ==> -$cnt);
  return $sorted_freqs;
}

/* HH_FIXME[4032] */
function main($filepath): void {
  try {
    $extract_words_typed = accept_types(HH\fun('ex23\extract_words'), "string");
    $remove_stop_words_typed = accept_types(
      HH\fun('ex23\remove_stop_words'),
      "vec<string>",
    );
    $frequencies_typed = accept_types(
      HH\fun('ex23\frequencies'),
      "vec<string>",
    );
    $sorted_typed = accept_types(
      HH\fun('ex23\sort'),
      "dict<string,integer>", // not int but integer to match with \gettype
    );

    $words = $extract_words_typed($filepath);
    $filtered = $remove_stop_words_typed($words);
    $word_freqs = $frequencies_typed($filtered);
    $sorted_freqs = $sorted_typed($word_freqs);
    foreach (Dict\take($sorted_freqs, 25) as $word => $cnt) {
      \print_r("{$word} - {$cnt}\n");
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
