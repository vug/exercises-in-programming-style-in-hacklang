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
            main_05_cookbook($input);
            break;
    }

    return 0;
  }

  <<__Override>>
  protected function getSupportedOptions(): vec<CLIOptions\CLIOption> {
    return vec[];
  }
}