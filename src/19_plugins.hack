namespace ex19;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

/**
 * A "poor's man plugin" implementation
 * Look like plugins (aka extensions in HHVM terminology) cannot be compiled independently of HHVM.
 * Even if it is an extension written in pure PHP it has to be placed in hphp/system/php folder of HHVM project.
 * See https://github.com/facebook/hhvm/tree/master/hphp/system/php
 * Then the php file including extension logic has to be added to php.txt
 * See https://github.com/facebook/hhvm/blob/master/hphp/system/php.txt
 * This will add the class/function defined in the extension to "SystemLib".
 * Compile HHVM again and the new extension will be part of the runtime.
 * Source: https://github.com/facebook/hhvm/wiki/Extension-API
 * 
 * Plugin style requires dynamically loading of separately compilable modules.
 * Here we are preparing a setup where the implementation of two functions change by setting values in config.ini file
 */
function load_plugins(
): shape(
  "words_func" => (function(string): vec<string>),
  "freqs_func" => (function(vec<string>): dict<int, string>),
) {

  $config = \parse_ini_file("src/19_plugins_config.ini");
  $file_to_func = dict[
    "src/19_plugins/words1.hack" => HH\fun('ex19\plugins\words1\extract_words'),
    "src/19_plugins/words2.hack" => HH\fun('ex19\plugins\words2\extract_words'),
    "src/19_plugins/frequencies1.hack" =>
      HH\fun('ex19\plugins\frequencies1\top25'),
    "src/19_plugins/frequencies2.hack" =>
      HH\fun('ex19\plugins\frequencies2\top25'),
  ];
  $words_func = $file_to_func[$config["words"]];
  $freqs_func = $file_to_func[$config["frequencies"]];
  return shape("words_func" => $words_func, "freqs_func" => $freqs_func);
}

function main(string $filepath): void {
  $functions = load_plugins();
  $words = $functions['words_func']($filepath);
  $top25_freqs = $functions['freqs_func']($words);
  foreach ($top25_freqs as $word => $cnt) {
    \print_r("{$word} - {$cnt}\n");
  }
}
