namespace ex01;
use HH\Lib\{C, Str, Vec};
use namespace Facebook\TypeAssert;
use HH;
use U;

// To check how much of the memory is being used.
// We are pretending that it has a limit of 1024.
function get_memsize(vec<mixed> $mem): int {
  return C\reduce(
    Vec\map($mem, $item ==> {
      if ($item is string) {
        return Str\length($item);
      } elseif (\is_hack_array($item)) {
        $item = TypeAssert\matches<vec<mixed>>($item);
        return C\count($item);
      }
      return 1;
    }),
    ($x, $y) ==> $x + $y,
    0,
  );
}

function main(string $filepath): void {
  try {
    // Limited memory of assumed size 1024.
    $mem = vec[];
    $mem[] = \file_get_contents(U\stop_words_file_path); // $mem[0] $stop_words
    $mem[] = ""; // $mem[1] is a $line from text
    $mem[] = null; // $mem[2] is $start_char_index of $word in line
    $mem[] = 0; // $mem[3] is the scanning index over line characters
    $mem[] = false; // $mem[4] is $is_word_in_freqs flag
    $mem[] = ""; // $mem[5] is current parsed $word from text
    $mem[] = ""; // $mem[6] is a line from word_frequency file in word,NNNN form
    $mem[] = 0; // $mem[7] is current word's occurrence frequency, $cnt

    /* 
    Because all words and their counts won't fit to memory
    we'll store them in a file in following format:
    20 chars for word, comma, 5 chars for count.
    Example:
        restrictions,0002
          whatsoever,0002
                copy,0012    
    */
    $word_freqs_file = \fopen("disk.txt", "a"); // touch to create
    \fclose($word_freqs_file);
    $word_freqs_file = \fopen("disk.txt", "r+"); // open
    $file = \fopen($filepath, "r");

    while (true) {
      $mem[1] = \fgets($file); // one line from text
      if ($mem[1] === false) { // end of input file
        break;
      }
      $mem[2] = null; // no word detected yet
      $mem[3] = 0; // scanning index is at the beginning of the line

      // TODO: get rid of $char variable and foreach loop style
      foreach (Str\split(TypeAssert\string($mem[1]), "") as $char) {
        if ($mem[2] === null) { // new word search
          if (
            !\ctype_space($char) && !\ctype_punct($char)
          ) { // found word beginning
            $mem[2] = $mem[3]; // store current index in word_start_index
          }
        } else { // going over found word, word start is known
          if (
            \ctype_space($char) || \ctype_punct($char)
          ) { // found end of the word
            $mem[4] = false; // not known whether this word is in freqs file yet
            $mem[5] = Str\lowercase(
              Str\slice( // slice the line from word beginning to word end index
                TypeAssert\string($mem[1]),
                TypeAssert\int($mem[2]),
                TypeAssert\int($mem[3]) - TypeAssert\int($mem[2]),
              ),
            );
            if ( // parsed word is long enough and not a stop word
              Str\length(TypeAssert\string($mem[5])) >= 2 &&
              !Str\contains(
                TypeAssert\string($mem[0]), // stop words
                TypeAssert\string($mem[5]), // detected word
              )
            ) {
              // Scan freqs file to search for current word
              while (true) {
                $mem[6] = \fgets($word_freqs_file); // word,NNN from freqs file
                if ($mem[6] === false) { // EOF.
                  break;
                }
                $mem[7] = (int)( // NNN from freqs file
                  Str\split(Str\trim(TypeAssert\string($mem[6])), ',')[1]
                );
                $mem[6] = Str\split( // word from freqs file
                  Str\trim(TypeAssert\string($mem[6])),
                  ',',
                )[0];
                if ($mem[5] === $mem[6]) { // current word exists in freqs file
                  $mem[7] = TypeAssert\int($mem[7]) + 1; // increase word count
                  $mem[4] = true; // flag that word is in freqs file
                  break;
                }
              }
              if (!$mem[4]) {
                \fseek($word_freqs_file, 0, 1); // ?
                // Set word count as 1
                \fputs(
                  $word_freqs_file,
                  Str\format("%20s,%04d\n", TypeAssert\string($mem[5]), 1),
                );
              } else {
                // rewind to the beginning of line to overwrite
                // rewrite line for the same word with increased count
                \fseek($word_freqs_file, -26, 1);
                \fputs(
                  $word_freqs_file,
                  Str\format(
                    "%20s,%04d\n",
                    TypeAssert\string($mem[5]),
                    TypeAssert\int($mem[7]),
                  ),
                );
              }
              // rewind to the beginning of the freqs file for the next scan
              \fseek($word_freqs_file, 0);
            }
            $mem[2] = null; // nullify word beginning index for the next line
          }
        }
        // move to the next character in text line
        $mem[3] = TypeAssert\int($mem[3]) + 1;
      }
    }
    \fclose($file);

    /*
    Top 25 words from word freqs file
    */
    $mem = vec[]; // empty memory. Meanings of the items will change.
    // first 25 items are for holding 25 words
    for ($i = 0; $i < 25; $i++) {
      $mem[] = null;
    }
    $mem[] = null; // $mem[25] is for least frequent word pushed out of top 25
    $mem[] = ""; // $mem[26] is word,freq from word_freqs file
    $mem[] = 0; // $mem[27] is frequency

    # scan word_freqs file
    while (true) {
      $mem[26] = \fgets($word_freqs_file);
      if ($mem[26] === false) { // EOF
        break;
      }
      $mem[27] = (int)( // NNN from freqs file
        Str\split(Str\trim(TypeAssert\string($mem[26])), ',')[1]
      );
      $mem[26] = Str\split( // word from freqs file
        Str\trim(TypeAssert\string($mem[26])),
        ',',
      )[0];
      // Check whether this word has more counts than the ones in mem
      for ($i = 0; $i < 25; $i++) { // go over current top25
        if (
          $mem[$i] === null ||
          TypeAssert\matches<(string, int)>($mem[$i])[1] <
            TypeAssert\int($mem[27])
        ) { // if word from word_freqs is more frequent then this top25 word
          // shift all words in top25 down from this index
          for ($j = 25; $j > $i; $j--) {
            $mem[$j] = $mem[$j - 1];
          }
          // put current word there
          $mem[$i] = tuple($mem[26], $mem[27]);
          break;
        }
      }
    }

    // Print top 25 words
    for ($i = 0; $i < 25; $i++) {
      if ($mem[$i] === null) {
        break;
      }
      \print_r(
        Str\format(
          "%s - %d\n",
          TypeAssert\matches<(string, int)>($mem[$i])[0],
          TypeAssert\matches<(string, int)>($mem[$i])[1],
        ),
      );
    }

    \fclose($word_freqs_file);
  } catch (\Exception $ex) {
    \print_r($ex->toString());
  } finally {
    \shell_exec("rm disk.txt");
  }
}
