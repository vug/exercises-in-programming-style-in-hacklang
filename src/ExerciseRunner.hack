use namespace Facebook\CLILib;
use namespace Facebook\CLILib\CLIOptions;

final class ExerciseRunner extends CLILib\CLIWithArguments {
  <<__Override>>
  public async function mainAsync(): Awaitable<int> {
    $argv = $this->getArgv();
    $exercise = $argv[1] ?? "05_cookbook.hack";
    $input = $argv[2] ?? "src/small_input.txt";

    switch ($exercise) {
      case "05_cookbook.hack":
        ex05\main2($input);
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
