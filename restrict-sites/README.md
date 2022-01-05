
## Restrict sites

---

The purpose of this script is to automatically close Chrome tabs containing a specific label. 
I decided to build this after I felt I spend way too much time looking at memes on sites such as *9GAG* and *Reddit*.

--- 

### *Important notes*:
- The script works only on `macOS`. I have only tested it on 2 macOS versions - "`Monterey`" and "`Big Sur`".
- It is not extensively tested, but as far as I can tell it works *OK*. If you stumble upon something, please [contact me](mailto:mladen.projects@gmail.com).
- Currently, the script can only read the title of the Chrome tabs and close them based on the given rule. I will soon add the option to choose between tab `title` and tab `URL`.
--- 
### *General info*:
The tool contains 2 files - `main.sh` and `killer.sh`. 
<br>The `killer.sh` is the script that monitors whether a restricted tab is opened and closes it. 
<br>The `main.sh` is more of a remote which controls the `killer.sh` script. 

--- 
### *Examples:*
1. Get Help
```bash
$ ./main.sh -h

 Usage: ./main.sh [-b] [-d] [-h] [-s]

  ---------------------------------
  -b | --block // Blocks given pages.
    Example:
    ./main.sh -b facebook youtube ...
  ---------------------------------
  -d | --deactivate //  Kills currently running sessions of the script.
  ---------------------------------
  -h | --help // Displays the help message.
  ---------------------------------
  -s | --status  // Shows what the script is currently blocking.
```

2. Add a site to the blocked list:
```bash
$ ./main.sh -b 9gag
[+] Blocking - 9gag
[+] Done! The process is running in the background!
```
3. Check currently blocked sites:
```bash
$ ./main.sh -s
[+] Currently blocking - 9gag facebook
```
4. Disable the tool completely:
```bash
$ ./main.sh -d
[+] Killed the running process(es) - 22097 22063
```
---
### *TODO*
- Add an option to choose between tab `title` or `URL`
- Add an option to remove single or multiple sites from the blocked list without completely deactivating it.
- Restart the process rather than spawning a new subprocess.
- Add an option to choose between different browsers. 