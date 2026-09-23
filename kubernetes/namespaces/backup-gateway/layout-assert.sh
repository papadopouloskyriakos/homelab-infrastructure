#!/bin/sh
# Hetzner layout assertion (IFRNLLEI01PRD-2850): the rule "nothing reaches
# Hetzner unencrypted" made measurable. Lists the project as Hetzner sees it:
#   * exactly one bucket, ours;
#   * every directory and object name under it is crypt-shaped (rclone crypt
#     "standard" names: unpadded base32, [a-z2-7], 26+ chars).
# A plaintext name, or a second bucket, means some consumer bypassed the
# gateway. Runs in the only namespace that holds the Hetzner key.
set -u
fail=0
want="${HZ_BUCKET:?HZ_BUCKET not set}"

buckets=$(rclone lsf hetzner: 2>&1) || { echo "FAIL: cannot list Hetzner project: $buckets"; exit 2; }
if [ "$buckets" != "${want}/" ]; then
  echo "FAIL: bucket list is not exactly ${want}/:"
  echo "$buckets"
  fail=1
else
  echo "ok: one bucket, ${want}"
fi

# --max-depth 3: bucket dir / consumer dir / first level inside (enough to catch
# a plaintext consumer without walking millions of Thanos chunks).
names=$(rclone lsf -R --max-depth 3 "hetzner:${want}" 2>&1) || { echo "FAIL: cannot list ${want}: $names"; exit 2; }
total=$(printf '%s\n' "$names" | sed '/^$/d' | wc -l)
bad=$(printf '%s\n' "$names" | sed '/^$/d' | tr '/' '\n' | sed '/^$/d' | grep -v -E '^[a-z2-7]{26,}$' || true)
if [ -n "$bad" ]; then
  echo "FAIL: $(printf '%s\n' "$bad" | wc -l) non-crypt name segment(s) on Hetzner (first 20):"
  printf '%s\n' "$bad" | head -20
  fail=1
else
  echo "ok: ${total} path(s) sampled, every segment crypt-shaped"
fi

exit $fail
