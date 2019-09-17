use namespace HH\Lib\{Str, Vec, C};
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
      // ex18 prints out extra lines
      if ($source_file === "18_aspects.hack") {
        $actual = Str\split($actual, "\n")
          |> Vec\filter($$, $line ==> !Str\contains($line, "ex18"))
          |> Str\join($$, "\n");
        // ex25 prints results in a different order
      } else if (
        C\contains(
          vec["02_go_forth.hack", "25_persistent_tables.hack"],
          $source_file,
        )
      ) {
        $actual = keyset(Str\split($actual, "\n"));
        $expected = keyset(Str\split($expected, "\n"));
      }
      expect($actual)->toBePHPEqual($expected);
    } finally {
      \shell_exec("rm test_tmp.txt");
    }
  }

  public function testSmallInput01(): void {
    self::compare_exercise("01_good_old_times.hack");
  }

  public function testSmallInput02(): void {
    self::compare_exercise("02_go_forth.hack");
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

  public function testSmallInput15(): void {
    self::compare_exercise("15_bulletin_board.hack");
  }

  public function testSmallInput16(): void {
    self::compare_exercise("16_introspective.hack");
  }

  public function testSmallInput18(): void {
    self::compare_exercise("18_aspects.hack");
  }

  public function testSmallInput19(): void {
    self::compare_exercise("19_plugins.hack");
  }

  public function testSmallInput20(): void {
    self::compare_exercise("20_constructivist.hack");
  }

  public function testSmallInput21(): void {
    self::compare_exercise("21_tantrum.hack");
  }

  public function testSmallInput22(): void {
    self::compare_exercise("22_passive_aggressive.hack");
  }

  public function testSmallInput23(): void {
    self::compare_exercise("23_declared_intentions.hack");
  }

  public function testSmallInput24(): void {
    self::compare_exercise("24_quarantine.hack");
  }

  public function testSmallInput25(): void {
    self::compare_exercise("25_persistent_tables.hack");
  }

  public function testSmallInput26(): void {
    self::compare_exercise("26_spreadsheet.hack");
  }

  public function testSmallInput27(): void {
    self::compare_exercise("27_lazy_rivers.hack");
  }

  public function testSmallInput30(): void {
    self::compare_exercise("30_map_reduce.hack");
  }

  public function testSmallInput31(): void {
    self::compare_exercise("31_double_map_reduce.hack");
  }

  public function testSmallInput32(): void {
    self::compare_exercise("32_trinity.hack");
  }
}
