# DynHosts
---

## About
* Copyright   ****  2016 [Dan Reidy](https://github.com/dubkat)



## Description
Generates an */etc/hosts* file based on DNS.

This script is really only useful if you
use AutoFS. If you find it useful. Awesomesauce.

AutoFS gets it's NFS (and if you use [sshfs](https://github.com/libfuse/sshfs) hosts from your [/etc/hosts](file:///etc/hosts) file.

## Files
 | Filename | Description |
 | :------------- | :------------- |
 | ** *dynhosts.sys* ** | Just a header file. |
 | ** *dynhosts.static* ** | A file containint the typical /etc/hosts  stuff you would expect, managed manually. |
 | ** *dynhosts.dyn* ** | A file containing a list of hostnames that will be turned into IP hostname lines after being resolved. |

* Just stick your hostnames in **dynhosts.dyn**, one per line, and the script will lookup it's IP and add it to your hosts.

* Add any static hosts to dynhosts.static.

* By default this script looks for these 3 config files in
**/usr/local/etc**. Edit the heading of the script to alter that.
