use function Facebook\FBExpect\expect;
use type Facebook\HackTest\{DataProvider, HackTest};

final class StyleTest extends HackTest {
  public static function compare_exercise(string $source_file): void {
    try {
      \shell_exec(
        "hhvm bin/run_exercise.hh src/{$source_file} texts/small_input.txt > test_tmp.txt",
      );
      $actual = \file_get_contents("test_tmp.txt");
      $expected = \file_get_contents("texts/small_input-top_words.txt");
      expect($actual)->toBePHPEqual($expected);
    } finally {
      \shell_exec("rm test_tmp.txt");
    }
  }

  public function testSmallInput04(): void {
    self::compare_exercise("04_cookbook.hack");
  }

  public function testSmallInput05(): void {
    self::compare_exercise("05_pipeline.hack");
  }

  public function testSmallInput06(): void {
    self::compare_exercise("06_code_golf.hack");
  }

  public function testSmallInput07(): void {
    self::compare_exercise("07_infinite_mirror.hack");
  }

  public function testSmallInput08(): void {
    self::compare_exercise("08_kick_forward.hack");
  }

  public function testSmallInput09(): void {
    self::compare_exercise("09_the_one.hack");
  }

  public function testSmallInput10(): void {
    self::compare_exercise("10_things.hack");
  }

  public function testSmallInput11(): void {
    self::compare_exercise("11_letterbox.hack");
  }

  public function testSmallInput12(): void {
    self::compare_exercise("12_closed_maps.hack");
  }

  public function testSmallInput13(): void {
    self::compare_exercise("13_abstract_things.hack");
  }

  public function testSmallInput14(): void {
    self::compare_exercise("14_hollywood.hack");
  }
}
