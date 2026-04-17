#!/usr/bin/env python3
"""
proc_monitor.py — Monitor CPU and memory usage of a named process.

Usage:
    python3 proc_monitor.py <process_name> [--interval <seconds>] [--count <n>]
                             [--cpu-warn <pct>] [--mem-warn <mb>]

Options:
    --interval   Sampling interval in seconds (default: 5)
    --count      Number of samples to collect, 0 = run forever (default: 0)
    --cpu-warn   Warn when CPU % exceeds this value (default: 80)
    --mem-warn   Warn when RSS memory (MB) exceeds this value (default: 500)

Example:
    python3 proc_monitor.py nginx --interval 10 --count 6 --cpu-warn 70
"""

import argparse
import signal
import sys
import time

try:
    import psutil
except ImportError:
    print("psutil is required: pip install psutil", file=sys.stderr)
    sys.exit(1)


def find_procs(name: str):
    """Return all running processes whose name or cmdline contains *name*."""
    matches = []
    for proc in psutil.process_iter(["pid", "name", "cmdline"]):
        try:
            pname = proc.info["name"] or ""
            cmdline = " ".join(proc.info["cmdline"] or [])
            if name.lower() in pname.lower() or name.lower() in cmdline.lower():
                matches.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return matches


def sample(procs, cpu_warn: float, mem_warn: float):
    """Print one sample line per process and return (total_cpu, total_mem_mb)."""
    total_cpu = 0.0
    total_mem = 0.0
    alive = []

    for proc in procs:
        try:
            cpu = proc.cpu_percent(interval=None)
            mem_mb = proc.memory_info().rss / (1024 * 1024)
            flags = []
            if cpu > cpu_warn:
                flags.append(f"CPU>{cpu_warn}%")
            if mem_mb > mem_warn:
                flags.append(f"MEM>{mem_warn}MB")
            flag_str = "  [WARN: " + ", ".join(flags) + "]" if flags else ""
            print(
                f"  PID {proc.pid:>7}  CPU {cpu:5.1f}%  MEM {mem_mb:8.1f} MB{flag_str}"
            )
            total_cpu += cpu
            total_mem += mem_mb
            alive.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            print(f"  PID {proc.pid:>7}  [gone]")

    return total_cpu, total_mem, alive


def main():
    parser = argparse.ArgumentParser(
        description="Monitor CPU and memory for a named process.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("process_name", help="Process name or substring to match")
    parser.add_argument("--interval", type=float, default=5, metavar="SECONDS")
    parser.add_argument("--count", type=int, default=0, metavar="N",
                        help="Samples to collect (0 = forever)")
    parser.add_argument("--cpu-warn", type=float, default=80, metavar="PCT")
    parser.add_argument("--mem-warn", type=float, default=500, metavar="MB")
    args = parser.parse_args()

    # Graceful exit on Ctrl-C
    signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))

    procs = find_procs(args.process_name)
    if not procs:
        print(f"No processes found matching '{args.process_name}'")
        sys.exit(1)

    print(f"Monitoring {len(procs)} process(es) matching '{args.process_name}'")
    print(f"Interval: {args.interval}s  |  CPU warn: {args.cpu_warn}%  |  MEM warn: {args.mem_warn} MB")
    print("-" * 60)

    # Prime cpu_percent (first call always returns 0.0)
    for p in procs:
        try:
            p.cpu_percent(interval=None)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    sample_num = 0
    while True:
        time.sleep(args.interval)
        sample_num += 1
        ts = time.strftime("%Y-%m-%d %H:%M:%S")
        print(f"\n[{ts}]  Sample #{sample_num}")
        total_cpu, total_mem, procs = sample(procs, args.cpu_warn, args.mem_warn)
        print(f"  Totals —  CPU {total_cpu:6.1f}%  MEM {total_mem:8.1f} MB")

        if not procs:
            print("All monitored processes have exited.")
            break

        if args.count > 0 and sample_num >= args.count:
            break

    print("\nDone.")


if __name__ == "__main__":
    main()
