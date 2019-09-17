namespace ex02;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

class G { // Stack Machine
  public static Vector<mixed> $stack = Vector {};
  public static Map<string, mixed> $heap = Map {};
}

// Stack Functions
function pop<reify Titem>(): Titem {
  $item = G::$stack->pop();
  return TypeAssert\matches<Titem>($item);
}

function push(mixed $item): void {
  G::$stack->add($item);
}

function extend(Traversable<mixed> $items): void {
  G::$stack->addAll($items);
}

// couldn't use generic types because we want to return a reference
function peak(): mixed {
  return G::$stack->lastValue();
}

function swap(): void {
  $top_two = Vector {G::$stack->pop(), G::$stack->pop()};
  G::$stack->addAll($top_two);
}

function size(): int {
  return C\count(G::$stack);
}

// Heap Functions
function get<reify Titem>(string $key): Titem {
  $item = G::$heap[$key];
  return TypeAssert\matches<Titem>($item);
}

function put(string $key, mixed $value): void {
  G::$heap[$key] = $value;
}

function del(string $key): void {
  G::$heap->removeKey($key);
}

// Program
function read_file(): void {
  push(\file_get_contents(pop<string>()));
}

function filter_chars(): void {
  push(re"/[\W_]+/");
  swap();
  push(Regex\replace(pop<string>(), pop<Regex\Pattern>(), ' '));
  push(Str\lowercase(pop<string>()));
}

function scan(): void {
  extend(U\split_python(pop<string>()));
}

function remove_stop_words(): void {
  push(
    Set::fromItems(Str\split(\file_get_contents(U\stop_words_file_path), ',')),
  );
  TypeAssert\matches<Set<string>>(peak())->addAll(
    Str\split(U\ascii_lowercase, ''),
  );

  put("stop_words", Set::fromItems(pop<Set<string>>()));
  put("words", Vector {});

  while (size() > 0) {
    if (
      C\contains_key(get<Set<string>>("stop_words"), TypeAssert\string(peak()))
    ) {
      pop<string>();
    } else {
      get<Vector<string>>("words")->add(pop<string>());
    }
  }

  extend(get<Vector<string>>("words"));
  del("stop_words");
  del("words");
}

function frequencies(): void {
  put("word_freqs", Map<string, int> {});
  while (size() > 0) {
    if (
      C\contains_key(
        get<Map<string, int>>("word_freqs"),
        TypeAssert\string(peak()),
      )
    ) {
      push(get<Map<string, int>>("word_freqs")[TypeAssert\string(peak())]);
      push(1);
      push(pop<int>() + pop<int>());
    } else {
      push(1);
    }
    swap();
    get<Map<string, int>>("word_freqs")[pop<string>()] = pop<int>();
  }

  push(get<Map<string, int>>("word_freqs"));
  del("word_freqs");
}

function sort(): void { // not in style
  extend(
    Vec\map_with_key(
      Dict\sort(dict(pop<Map<string, int>>())),
      // Dict\sort_by(dict(pop<Map<string, int>>()), $cnt ==> -$cnt),
      ($word, $cnt) ==> tuple($word, $cnt),
    ),
  );
  // extend(Dict\sort_by(dict(pop<Map<string, int>>()), $cnt ==> -$cnt));
}

function main(string $filepath): void {
  try {
    push($filepath);
    read_file();
    filter_chars();
    scan();
    remove_stop_words();
    frequencies();
    sort();

    push(0);
    while (TypeAssert\int(peak()) < 25 && size() > 1) {
      put("index", pop<int>());
      list($word, $cnt) = pop<(string, int)>();
      \print_r("{$word} - {$cnt}\n");
      push(get<int>("index"));
      push(1);
      push(pop<int>() + pop<int>());
    }
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  }
}
