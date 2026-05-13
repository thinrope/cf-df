# cf-df
## copy.fail + copy-fail-2 + Dirty Frag + Fragnesia patching-on-the-fly

Patch [copy.fail](https://copy.fail/), [copy-fail-2](https://afflicted.sh/blog/posts/copy-fail-2.html), [Dirty frag](https://github.com/V4bel/dirtyfrag) and [Fragnesia](https://github.com/v12-security/pocs/tree/main/fragnesia) related CVEs, iff you need to.

The proper fixes for copy.fail, copy-fail-2 and Dirty frag were incorporated in the kernel on 2026-05-11.

**HOWEVER** A similar bug named [Fragnesia](https://github.com/v12-security/pocs/tree/main/fragnesia) in the same subsystems was just announced, so this mitigation is still valid. Potential [patch](https://lore.kernel.org/netdev/20260513041635.1289541-1-vakzz@zellic.io/) was announced.

## Why?
I suddenly needed to patch a multitude of linux hosts in various platforms with minimal impact.
I don't trust the suggested method of disabling module loading, I'd rather have the file renamed (or even deleted at some point).

## How?
Execute the `cf+df_patching.sh` script as root on any host. Use and configuration management system you have in place.
Alternatively, for those odd mass cases, use the wonderful GNU parallel[5] from a central host via ssh (run as root, ssh as root[3,4]):

````bash
git clone https://github.com/thinrope/cf-df.git
cd cf-df
$EDITOR target.list
parallel --tag --nonall --slf target.list --workdir ... --transferfile cf+df_patching.sh --cleanup 'bash cf+df_patching.sh'
````

## References
1.	copy.fail: https://copy.fail/
2.	copy-fail-2 CVE-2026-31431: https://afflicted.sh/blog/posts/copy-fail-2.html
3.	Dirty frag CVE-2026-43500: https://github.com/V4bel/dirtyfrag
4.	If you cannot login via ssh directly as root, use sudo properly
5.	... or abuse these CVEs before you patch to obtain root :-D
6.	GNU parallel: https://www.gnu.org/software/parallel/
7.	Fragresia CVE-2026-?????: https://github.com/v12-security/pocs/tree/main/fragnesia

## Notes and Thoughts; Limitations
* this script will not fix kernels with built-in (=y, not =m) options
    * this may be fixed by a proper bootcmdline (and reboot)
    * WSL2 seems to be in this category
    * if the modules are not present and not loadded the script may exit cleanly (giving false security, in this case)
* it does not check kernel version, so a non-vulnerable kernel (e.g. 7.0.5, 6.18.28) will have those modules disabled as well
* beware of nested implementations (VMs, WSL2, KVM, Docker, chroot, ...): they usually require different approach
* beware of rebooting to a different vulnerable kernel (this script patches the running kernel only per `uname -r`)
* While [Fragnesia](https://github.com/v12-security/pocs/tree/main/fragnesia) (no official CVE yet) is in the same modules, they are still renamed with previous CVEs; this does not diminish the script efficiency.

**NOTE**:
- At 2026-05-11T06:22:00Z three of four CVEs has been fixed in stable 7.0.6 and longterm 6.18.29 Linux kernel, see https://www.kernel.org/
- The fourth, [Fragnesia](https://github.com/v12-security/pocs/tree/main/fragnesia) (no official CVE yet), is not fixed yet
