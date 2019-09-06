use namespace Facebook\CLILib;
use namespace Facebook\CLILib\CLIOptions;

final class ExerciseRunner extends CLILib\CLIWithArguments {
  <<__Override>>
  public async function mainAsync(): Awaitable<int> {
    $argv = $this->getArgv();
    $exercise = $argv[1] ?? "src/04_cookbook.hack";
    $input = $argv[2] ?? "texts/small_input.txt";

    switch ($exercise) {
      case "src/04_cookbook.hack":
        ex04\main($input);
        break;
      case "src/05_pipeline.hack":
        ex05\main($input);
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
