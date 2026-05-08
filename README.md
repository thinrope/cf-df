# cf-df
## copy.fail + Dirty Frag patching-on-the-fly

Patch [copy.fail](https://copy.fail/) and [Dirty frag](https://github.com/V4bel/dirtyfrag) related CVEs

## Why?
I suddenly needed to patch a multitude of linux hosts in various platforms with minimal impact.
I don't trust the suggested method of disabling module loading, I'd rather have the file renamed (or even deleted at some point).

## How?
Execute the `cf+df_patching.sh` script as root on any host. Use and configuration management system you have in place.
Alternatively, for those odd mass cases, use the wonderfull GNU parallel[5] from a central host via ssh (run as root, ssh as root[3,4]):

````bash
git clone https://github.com/thinrope/cf-df.git
cd cf-df
$EDITOR target.list
parallel --tag --nonall --slf target.list --workdir ... --transferfile cf+df_patching.sh --cleanup 'bash cf+df_patching.sh'
````

## References
1.	copy.fail: https://copy.fail/
2.	Dirty frag: https://github.com/V4bel/dirtyfrag
3.	If you cannot login via ssh directly as root, use sudo properly
4.	... or abuse these CVEs before you patch to obtain root :-D
5.	GNU parallel: https://www.gnu.org/software/parallel/
