# sre-utils

A collection of utility scripts for Site Reliability Engineers.
Each script is standalone and requires no external dependencies beyond standard Unix/Linux tools.

---

## Tools

| Script | Language | Purpose |
|--------|----------|---------|
| `health_check.sh` | Bash | HTTP endpoint health check with status summary |
| `disk_usage.sh` | Bash | Disk usage report with configurable threshold alerts |
| `port_check.sh` | Bash | Check if TCP ports are open on one or more hosts |
| `log_errors.sh` | Bash | Scan log files for ERROR/WARN patterns and summarise |
| `proc_monitor.py` | Python3 | Monitor CPU & memory for a named process |

---

## Usage

All scripts are executable. Make them runnable if needed:

```bash
chmod +x sre-utils/*.sh
```

See each script's `--help` flag or the inline comments for detailed usage.
