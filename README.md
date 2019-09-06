# Setup

* Install HHVM: https://docs.hhvm.com/hhvm/installation/linux
* Install Composer: https://getcomposer.org/ (requires PHP)
* Using composer, install dependencies: `php composer.phar install`
* Get Pride and Prejudice `wget https://raw.githubusercontent.com/crista/exercises-in-programming-style/master/pride-and-prejudice.txt`

# Run a Style Exercise

```
hhvm bin/run_exercise.hh EXERCISE INPUT
```

For example, run following command from project folder.

```
hhvm bin/run_exercise.hh src/05_cookbook.hack src/small_input.txt
```

it outputs

```
live - 2
mostly - 2
white - 1
tigers - 1
india - 1
wild - 1
lions - 1
africa - 1
```
