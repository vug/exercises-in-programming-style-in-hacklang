# Remote HHVM Development

## Install HHVM

* [Getting Started](https://docs.hhvm.com/hhvm/getting-started/getting-started)
* [Installation: Windows](https://docs.hhvm.com/hhvm/installation/windows) does not exist yet. :-( Apparanetly, FB doesn't think it is *impactful*.
* [Installation: Linux](https://docs.hhvm.com/hhvm/installation/linux) Looks like my EC2 on AWS is an Ubuntu machine. Just followed the instructions.

```bash
sudo apt-get update
sudo apt-get install software-properties-common apt-transport-https
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xB4112585D386EB94

sudo add-apt-repository https://dl.hhvm.com/ubuntu
sudo apt-get update
sudo apt-get install hhvm
```

installed `hhvm (4.19.0-1~bionic)`

```plain
********************************************************************
* HHVM is installed.
*
* The best way to get started is to use HHVM's built-in webserver:
*
* $ hhvm -m server -p 8080
*
* Running command-line scripts with HHVM requires no special setup:
*
* $ hhvm example.hack
*
* FastCGI is also supported; see https://docs.hhvm.com/hhvm/advanced-usage/fastCGI
*
********************************************************************
```

## Setup Hack Studies 

* Create a folder `~/misc/hack`
* In that folder `touch .hhconfig`. `hh_client` needs this even if its empty.
* `hh_client` (this is `hh` at work) first time run

```plain
For more detailed logs, try `tail -f $(hh_client --monitor-logname) $(hh_client --logname)`
Server launched with the following command:
        '/opt/hhvm/4.19.0/bin/hh_server' '-d' '/home/ubuntu/misc/hack' '--waiting-client' '6'
Spawned typechecker (child pid=23417)
Logs will go to /tmp/hh_server/monitor_logs/zShomezSubuntuzSmisczShack-2019-08-24-16-52-57.monitor_log
No errors!
```

* [Basic Usage: Command Line](https://docs.hhvm.com/hhvm/basic-usage/command-line)
* Create `fibonacci.hack` and copy example code from above example.
* `hhvm fibonacci.hack 10` returns `The 10 number in fibonacci is: 55`

* [Getting Started: Starting A Real Project](https://docs.hhvm.com/hack/getting-started/starting-a-real-project)
* Install `composer`
    * Blog post about the release of [HHVM 4\.0\.0 \| HHVM](https://hhvm.com/blog/2019/02/11/hhvm-4.0.0.html) says "HHVM is no longer able to execute Composer; Composer 1.8.4 includes support for identifying the HHVM version when executing via PHP, which is how we currently recommend installing dependencies for Hack projects. We are currently working to move to a package manager that fully supports multiple languages." I think I need PHP to install Composer.
    * `sudo apt install php-cli` (install PHP 7.2 stuff on Ubuntu 18.04) Got the `apt` command from [How To Install and Use Composer on Ubuntu 18\.04 \| DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-18-04).
    * See "Command-line installation" in [Composer](https://getcomposer.org/download/). Now that we have `php` command.
    * `php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"`
    * `php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"` -> "Installer verified"
    * `php composer-setup.php` -> "Composer (version 1.9.0) successfully installed to: /home/ubuntu/misc/hack/composer.phar"
    * `php -r "unlink('composer-setup.php');"`
* Create `src/`, `tests/`, `bin/` subdirectories. `mkdir bin src tests`
* `php composer.phar require hhvm/hsl hhvm/hhvm-autoload`
```plain
Using version ^4.15 for hhvm/hsl
Using version ^2.0 for hhvm/hhvm-autoload
./composer.json has been created
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 2 installs, 0 updates, 0 removals
  - Installing hhvm/hsl (v4.15.1): Downloading (100%)
  - Installing hhvm/hhvm-autoload (v2.0.7): Downloading (100%)
Writing lock file
Generating autoload files
/home/ubuntu/misc/hack/vendor/autoload.hack               
```
* `php composer.phar require --dev hhvm/hhast hhvm/hacktest facebook/fbexpect`
```plain
Using version ^4.15 for hhvm/hhast
Using version ^1.6 for hhvm/hacktest
Using version ^2.6 for facebook/fbexpect
./composer.json has been updated
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 7 installs, 0 updates, 0 removals
  - Installing facebook/difflib (v1.2.0): Downloading (100%)
  - Installing hhvm/type-assert (v3.6.2): Downloading (100%)
  - Installing hhvm/hsl-experimental (v4.7.0): Downloading (100%)
  - Installing facebook/hh-clilib (v2.2.0): Downloading (100%)
  - Installing hhvm/hacktest (v1.6.1): Downloading (100%)
  - Installing facebook/fbexpect (v2.6.0): Downloading (100%)
  - Installing hhvm/hhast (v4.15.1): Downloading (100%)
Writing lock file
Generating autoload files
/home/ubuntu/misc/hack/vendor/autoload.hack
```
* Linter
    * `touch hhast-lint.json`
    * copy its content from "Starting A Real Project" page

## Remote Development with VS Code

* [Visual Studio Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
* [Developing on Remote Machines using SSH and Visual Studio Code](https://code.visualstudio.com/docs/remote/ssh)
* Install SSH extension
* I already had my `~/.ssh/config` file where my AWS EC2 instance is saved as `ugur_ec2` alias.
* In Command Palette: "Remote SSH: Connect to Host..."
* `ugur_ec2` appeared in the list. Choose that to establish an SSH connection to my "dev server".
* Terminal > New Terminal.
* `tmux attach -t main` I've a persistent (connetion-independent) terminal now.


## Install Hack Extension for VS Code

* In the remote VS Code window, go to Extensions, search "Hack"
* Install [Hack \- Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=pranayagarwal.vscode-hack) (Made by Slack). reload.
* Extensions > SSH: UGUR_EC2 - Installed > Hack > Click on Gear Icon on bottom right > Configure Extension Settings (This gives a UI for settings instead of dealing with)
* There are User, Remote, Workspace settings.
* By now I should have `vendor/bin/hhast-lint`
* In Remote, check "Hack> Remote: Enabled". Also verify that "Hack: Use Hhast" and "Hack: Use Language Server" are enabled.
* (Might need to restart VS Code) and Voila!
* Now I can hover over code get linter messages, and errors indicated etc.
* There were some duplicate file that were generating errors. Their clones are in `vendor/bin/`. Rename the clones to `.hack2`
    * vendor/hhvm/hhvm-autoload/bin/hh-autoload.hack
    * vendor/hhvm/hhast/bin/hhast-migrate.hack 
    * vendor/hhvm/hhast/bin/hhast-lint.hack
    * vendor/hhvm/hhast/bin/hhast-inspect.hack  
    * vendor/hhvm/hacktest/bin/hacktest.hack 


## Commands
* `hhvm src/hello.hack`
* One test file: `vendor/bin/hacktest tests/MyTest.hack`
* All tests: `vendor/bin/hacktest tests/`
* Run auto-loader to gather class -> file information: `vendor/bin/hh-autoload`
* To remove extensions: `php composer.phar remove hhvm/hsl`

## Blog Posts
* [HHVM 3\.28\.2 and 3\.27\.3 \| HHVM](https://hhvm.com/blog/2018/09/28/hhvm-3.28.2.html) New attribute `«__Entrypoint»`

## Misc
* [PHP: Language Reference \- Manual](https://www.php.net/manual/en/langref.php)
* [PHP style guide with coding standards and best practices\.](https://gist.github.com/ryansechrest/8138375)
* [hhvm/hh\-clilib: Command Line Interface \(CLI\) Library for the Hack programming language](https://github.com/hhvm/hh-clilib)
* [hhast/linters\-usage\.md at master · hhvm/hhast](https://github.com/hhvm/hhast/blob/master/docs/linters-usage.md)
* [hhvm/fbexpect: A Hack library for writing unit tests expressively](https://github.com/hhvm/fbexpect)


## Get pride-and-prejudice
* `wget https://raw.githubusercontent.com/crista/exercises-in-programming-style/master/pride-and-prejudice.txt`