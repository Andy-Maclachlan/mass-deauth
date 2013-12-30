DO NOT USE THIS SCRIPT AGAINST NETWORKS YOU DON'T OWN OR DON'T HAVE PERMISSION TO ATTACK!
-----------------------------------------------------------------------------------------

If you need to reach me for whatever reason, regarding this script, you can email me <grant.c.stone@gmail.com>, make a comment regarding your issue on my [weblog][1], or via the GitHub [page][2] for this script. This script was originally heavily influenced by [Leg3nd's Elegant Mass DeAuth Script][3]. And greatly improved with help from [Justin Welenofsky][4] and [Trevelyn][5] of [WeakNet Labs][6].
[1]: http://rfkiller.they.org "weblog"
[2]: https://github.com/RFKiller/mass-deauth
[3]: http://jasagerpwn.googlecode.com/svn/trunk/src/deauth.sh
[4]: https://plus.google.com/+JustinWelenofsky "Justin Welenofsky"
[5]: https://www.facebook.com/80211hacker "Trevelyn"
[6]: http://weaknetlabs.com "WeakNet Labs"

RFKiller's Mass-Deauth Script TODO list:
- [x] fix issue #1 (variable $ourAPmac being ignored)
- [x] add run-as-root check
- [x] check for required programs before running
- [x] ask for user input so user doesn't need to edit script manually before running it.
- [x] add commandline arguments/options
- [x] give users choice of using commandline options or being asked for variables at runtime.

Usage: ./mass-deauth [OPTIONS] [ARGUMENTS]

Example: ./mass-deauth -d 10 -w 30 -m 11:22:33:44:55:66 -i wlan0
