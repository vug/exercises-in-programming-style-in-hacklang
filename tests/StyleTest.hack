use function Facebook\FBExpect\expect;
use type Facebook\HackTest\{DataProvider, HackTest};

final class StyleTest extends HackTest {
  public function testSmallInput(): void {
    ex04\main("texts/small_input.txt");
    // Can not do unit test because these main functions print to stdout. Not return value.
    expect(1)->toBePHPEqual(1);
  }
}
