DO NOT USE THIS SCRIPT AGAINST NETWORKS YOU DON'T OWN OR DON'T HAVE PERMISSION TO ATTACK!
-----------------------------------------------------------------------------------------

If you need to reach me for whatever reason, regarding this script, you can email me <grant.c.stone@gmail.com>, or via the GitHub [page][1] for this script. This script was originally heavily influenced by [Leg3nd's Elegant Mass DeAuth Script][2], and greatly improved with help from [Trevelyn][3] of [WeakNet Labs][4] as well as some suggestions by Justin Welenofsky (hope I spelled that right).
[1]: https://github.com/RFKiller/mass-deauth
[2]: http://jasagerpwn.googlecode.com/svn/trunk/src/deauth.sh
[3]: https://www.facebook.com/80211hacker "Trevelyn"
[4]: http://weaknetlabs.com "WeakNet Labs"

RFKiller's Mass-Deauth Script TODO list:
- [ ] fix issue #1 (variable $ourAPmac being ignored)
- [x] add run-as-root check
- [x] check for required programs before running
- [x] ask for user input so user doesn't need to edit script manually before running it.
- [x] add commandline arguments/options
- [x] give users choice of using commandline options or being asked for variables at runtime.

Usage: ./mass-deauth.sh [OPTIONS] [ARGUMENTS]

Example: ./mass-deauth.sh -d 10 -w 30 -m 11:22:33:44:55:66 -i wlan0

If you have any suggestions, bug reports, "feature" requests, etc., - contact me and I will do what I can. Don't forget to stop over at [WeakNet Labs][4] and say "Hi" to Trevelyn! He is developing some really interesting projects, so check them out while you're there!
