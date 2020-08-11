# Recon tool based on [LazyRecon](https://github.com/nahamsec/lazyrecon) & [MagicRecon](https://github.com/robotshell/magicRecon)

```
__________        ___.    .__       /\         __________
\______   \  ____ \_ |__  |__|  ____)/  ______ \______   \  ____   ____   ____    ____
 |       _/ /  _ \ | __ \ |  | /    \  /  ___/  |       _/_/ __ \_/ ___\ /  _ \  /    \
 |    |   \(  <_> )| \_\ \|  ||   |  \ \___ \   |    |   \\  ___/\  \___(  <_> )|   |  \
 |____|_  / \____/ |___  /|__||___|  //____  >  |____|_  / \___  >\___  >\____/ |___|  /
        \/             \/          \/      \/          \/      \/     \/             \/
        
```
 
 
 - [x] Supports colors and is optimized for bash
 - [x] Static definition of output and tool directories at top of script for easy customization
 - [x] Error checks for logging and debugging
 - [x] Optimized for multi-threading where possible using [Interlace](https://github.com/codingo/Interlace)
 - [ ] Add logging to support scripts (use files!)
 - [ ] Rewrite LazyRecon for Interlace and debugging!
 - [ ] Support recursion over subdomains
 - [ ] Move functions from scan.sh to this script for recursiveness
 - [x] Add checking for SQLI automatically
 - [x] Add checking for request smuggling automatically
 - [ ] Refactor to have 1 main script and 2 sub-scripts: 1 for recon and one for vuln detection.
 - [ ] Rewrite in Python?
  
 
