final class MyCLI extends Facebook\CLILib\CLIWithArguments  {
    <<__Override>>
    protected function getSupportedOptions(): vec<Facebook\CLILib\CLIOptions\CLIOption> {
        return vec[];
    }
    
    <<__Override>>
    public async function mainAsync(): Awaitable<int> {
        echo "Hi! " . HH\Lib\Str\join($this->getArguments(), ' ') . "\n";
        return 0;
    }
}
