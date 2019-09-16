use namespace Facebook\CLILib;
use namespace Facebook\CLILib\CLIOptions;

final class ExerciseRunner extends CLILib\CLIWithArguments {
  <<__Override>>
  public async function mainAsync(): Awaitable<int> {
    $argv = $this->getArgv();
    $exercise = $argv[1] ?? "src/04_cookbook.hack";
    $input = $argv[2] ?? "texts/small_input.txt";

    switch ($exercise) {
      case "src/01_good_old_times.hack":
        ex01\main($input);
        break;
      case "src/04_cookbook.hack":
        ex04\main($input);
        break;
      case "src/05_pipeline.hack":
        ex05\main($input);
        break;
      case "src/06_code_golf.hack":
        ex06\main($input);
        break;
      case "src/07_infinite_mirror.hack":
        ex07\main($input);
        break;
      case "src/08_kick_forward.hack":
        ex08\main($input);
        break;
      case "src/09_the_one.hack":
        ex09\main($input);
        break;
      case "src/10_things.hack":
        ex10\main($input);
        break;
      case "src/11_letterbox.hack":
        ex11\main($input);
        break;
      case "src/12_closed_maps.hack":
        ex12\main($input);
        break;
      case "src/13_abstract_things.hack":
        ex13\main($input);
        break;
      case "src/14_hollywood.hack":
        ex14\main($input);
        break;
      case "src/15_bulletin_board.hack":
        ex15\main($input);
        break;
      case "src/16_introspective.hack":
        ex16\main($input);
        break;
      case "src/18_aspects.hack":
        ex18\main($input);
        break;
      case "src/19_plugins.hack":
        ex19\main($input);
        break;
      case "src/20_constructivist.hack":
        ex20\main($input);
        break;
      case "src/21_tantrum.hack":
        ex21\main($input);
        break;
      case "src/22_passive_aggressive.hack":
        ex22\main($input);
        break;
      case "src/23_declared_intentions.hack":
        ex23\main($input);
        break;
      case "src/24_quarantine.hack":
        ex24\main($input);
        break;
      case "src/25_persistent_tables.hack":
        ex25\main($input);
        break;
      case "src/26_spreadsheet.hack":
        ex26\main($input);
        break;
      case "src/27_lazy_rivers.hack":
        ex27\main($input);
        break;
      case "src/30_map_reduce.hack":
        await ex30\main($input);
        break;
      case "src/31_double_map_reduce.hack":
        ex31\main($input);
        break;
      case "src/32_trinity.hack":
        await ex32\main($input, $this->getStdin());
        break;
      default:
        \print_r("Exercise \"{$exercise}\" does not exist.\n");
    }
    return 0;
  }

  <<__Override>>
  protected function getSupportedOptions(): vec<CLIOptions\CLIOption> {
    return vec[];
  }
}
