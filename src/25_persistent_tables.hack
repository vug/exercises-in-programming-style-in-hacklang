namespace ex25;
use HH\Lib\{C, Dict, Keyset, Regex, Str, Vec};
use namespace Facebook\{TypeAssert, TypeCoerce, TypeSpec};
use HH;
use U;

function get_rows<reify TRow>(\SQLite3Result $result): vec<TRow> {
  $rows = vec[];
  while (($row = $result->fetcharray(\SQLITE3_ASSOC)) !== false) {
    $rows[] = TypeAssert\matches<TRow>($row);
  }
  $result->finalize();
  return $rows;
}

function create_db_schema(\SQLite3 $db): void {
  $table_creation_queries = vec[
    'CREATE TABLE documents (id INTEGER PRIMARY KEY AUTOINCREMENT, name)',
    'CREATE TABLE words (id, doc_id, word)',
    'CREATE TABLE characters (id, word_id, character)',
  ];
  Vec\map($table_creation_queries, $q ==> $db->query($q));
}

function load_file_into_database(\SQLite3 $db, string $filepath): void {
  $extract_words = (string $filepath): vec<string> ==> {
    $text = \file_get_contents($filepath);
    $replaced = Regex\replace($text, re"/[\W_]+/", ' ');
    $lowered = Str\lowercase($replaced);
    $words = U\split_python($lowered);

    $stop_text = \file_get_contents(U\stop_words_file_path);
    $stop_words = keyset(
      Vec\concat(Str\split($stop_text, ','), Str\split(U\ascii_lowercase, '')),
    );
    return Vec\filter($words, $word ==> !C\contains_key($stop_words, $word));
  };

  $words = $extract_words($filepath);

  // YOLO-QL: no injection detection. Use SQLite3Stmt for statement construction.
  $db->query("INSERT INTO documents (name) VALUES ('{$filepath}')");
  $res = $db->query(
    "SELECT id FROM documents WHERE name='{$filepath}' LIMIT 1",
  );
  $doc_ids = get_rows<shape("id" => int)>($res);
  $doc_id = $doc_ids[0]['id'];

  # Add the words to the database
  $res = $db->query("SELECT MAX(id) AS word_id FROM words");
  $word_ids = get_rows<shape("word_id" => ?int)>($res);
  $word_id = $word_ids[0]['word_id'] ?? 0;
  foreach ($words as $word) {
    $db->query("INSERT INTO words VALUES ({$word_id}, {$doc_id}, '{$word}')");
    $char_id = 0;
    // Storing characters slows down a lot.
    foreach (Str\split($word, '') as $char) {
      $db->query(
        "INSERT INTO characters VALUES ({$char_id}, {$word_id}, '{$char}')",
      );
      $char_id += 1;
    }
    $word_id += 1;
  }
}


function main(string $filepath): void {
  try {
    $db_path = "src/25_tf.db";
    $db_exists = \file_exists($db_path);
    $db = new \SQLite3($db_path);
    if (!$db_exists) {
      create_db_schema($db);
      load_file_into_database($db, $filepath);
    }
    $query = <<< SQL
SELECT
  doc_id,
  word, 
  COUNT(*) AS cnt 
FROM words
JOIN (
  SELECT 
    id
  FROM documents
  WHERE name = '{$filepath}'
) doc ON doc.id = words.doc_id
GROUP BY 
  word 
ORDER BY cnt DESC
LIMIT 25
SQL;
    $res = $db->query($query);
    $word_freqs = get_rows<
      shape("doc_id" => int, "word" => string, "cnt" => int),
    >($res);
    foreach ($word_freqs as $row) {
      \print_r("{$row['word']} - {$row['cnt']}\n");
    }

    $db->close();
  } catch (\Exception $ex) {
    \print_r($ex->getMessage());
  }
}
