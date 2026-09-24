"""Backup-gateway canary: a real S3 write/read/delete through the gateway.

Two objects: 1 MiB (small-object path) and 64 MiB (crosses the gateway's
multipart cutoff, so the streaming upload to Hetzner is exercised). Both are
verified by SHA256 on the way back and deleted afterwards. Uses the gateway's
LOCAL key pair only; nothing here can reach Hetzner directly.
Keys carry the pod name: all three sites share one bucket and one crypt key, so
a fixed key is the SAME Hetzner object everywhere and the sites' canaries, all
on one schedule, deleted and overwrote each other mid-check.
Exit 1 on any mismatch or non-2xx. (IFRNLLEI01PRD-2850)
"""
import datetime
import hashlib
import hmac
import os
import secrets
import sys
import urllib.error
import urllib.parse
import urllib.request

AK, SK = os.environ["ACCESS_KEY_ID"], os.environ["ACCESS_SECRET_KEY"]
ENDPOINT = os.environ["S3_ENDPOINT"].rstrip("/")
BUCKET = os.environ.get("S3_BUCKET", "backup-canary")
RUN = os.environ.get("HOSTNAME") or secrets.token_hex(8)
REGION, SERVICE = "us-east-1", "s3"
HOST = urllib.parse.urlparse(ENDPOINT).netloc


def sv4(method, path, body=b"", stream=False):
    t = datetime.datetime.now(datetime.UTC)
    amz, ds = t.strftime("%Y%m%dT%H%M%SZ"), t.strftime("%Y%m%d")
    ph = hashlib.sha256(body).hexdigest()
    ch = "host:%s\nREDACTED_3c0ef42e:%s\nx-amz-date:%s\n" % (HOST, ph, amz)
    sh = "host;REDACTED_3c0ef42e;x-amz-date"
    cr = "%s\n%s\n\n%s\n%s\n%s" % (method, path, ch, sh, ph)
    scope = "%s/%s/%s/aws4_request" % (ds, REGION, SERVICE)
    sts = "AWS4-HMAC-SHA256\n%s\n%s\n%s" % (amz, scope, hashlib.sha256(cr.encode()).hexdigest())
    k = hmac.new(("AWS4" + SK).encode(), ds.encode(), hashlib.sha256).digest()
    for x in (REGION, SERVICE, "aws4_request"):
        k = hmac.new(k, x.encode(), hashlib.sha256).digest()
    sig = hmac.new(k, sts.encode(), hashlib.sha256).hexdigest()
    r = urllib.request.Request(ENDPOINT + path, data=body if method == "PUT" else None, method=method)
    r.add_header("x-amz-date", amz)
    r.add_header("REDACTED_3c0ef42e", ph)
    r.add_header("Authorization",
                 "AWS4-HMAC-SHA256 Credential=%s/%s, SignedHeaders=%s, Signature=%s" % (AK, scope, sh, sig))
    try:
        resp = urllib.request.urlopen(r, timeout=900)
    except urllib.error.HTTPError as e:
        return e.code, e.read()
    if not stream:
        return resp.status, resp.read()
    h, n = hashlib.sha256(), 0
    while True:
        b = resp.read(1 << 22)
        if not b:
            break
        h.update(b)
        n += len(b)
    return resp.status, (n, h.hexdigest())


fail = 0
for name, size in (("small.bin", 1 << 20), ("multipart.bin", 64 << 20)):
    blob = secrets.token_bytes(size)
    want = hashlib.sha256(blob).hexdigest()
    key = "/%s/canary-%s-%s" % (BUCKET, RUN, name)
    st_put, body = sv4("PUT", key, blob)
    st_get, got = sv4("GET", key, stream=True)
    st_del, _ = sv4("DELETE", key)
    ok = st_put in (200, 201) and st_get == 200 and got == (size, want) and st_del in (200, 204)
    print("%s %s: put=%s get=%s del=%s bytes=%s sha_ok=%s" % (
        "ok" if ok else "FAIL", name, st_put, st_get, st_del,
        got[0] if st_get == 200 else "-", got == (size, want) if st_get == 200 else False))
    if not ok:
        if st_put not in (200, 201):
            print("  put body: %s" % body[:300].decode(errors="replace"))
        fail = 1

sys.exit(fail)
