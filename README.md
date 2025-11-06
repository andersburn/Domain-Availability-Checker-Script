<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>.dk Domain Checker – Description & Guide</title>
<style>
  body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;line-height:1.6;margin:0;padding:0 1rem 3rem;color:#111}
  header{padding:2rem 0}
  h1{margin:0 0 .25rem}
  h2{margin:2rem 0 .5rem}
  .lead{color:#444}
  code,kbd,pre{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:.95rem}
  pre{background:#0f172a0d;border:1px solid #e5e7eb;border-radius:8px;padding:1rem;overflow:auto}
  .pill{display:inline-block;background:#eef6ff;color:#0b63ce;border:1px solid #cde0ff;border-radius:999px;padding:.15rem .6rem;font-size:.85rem;margin-right:.3rem}
  ul{margin:.25rem 0 1rem 1.2rem}
  .grid{display:grid;grid-template-columns:1fr;gap:1rem}
  @media(min-width:800px){.grid{grid-template-columns:1fr 1fr}}
  table{width:100%;border-collapse:collapse;margin:1rem 0}
  th,td{border:1px solid #e5e7eb;padding:.6rem .7rem;text-align:left;vertical-align:top}
  th{background:#fafafa}
  .note{background:#fffceb;border:1px solid #fde68a;padding:1rem;border-radius:8px}
  footer{margin-top:3rem;color:#666;font-size:.9rem}
</style>
</head>
<body>

<header>
  <h1>.dk Domain Checker Script</h1>
  <p class="lead">Checks availability of domains composed of letters and numbers within a chosen length range, querying Punktum.dk WHOIS with rate limiting.</p>
  <div>
    <span class="pill">Configurable TLD</span>
    <span class="pill">Rate limit</span>
    <span class="pill">Min/Max length</span>
    <span class="pill">a–z, 0–9</span>
    <span class="pill">Free/Taken outputs</span>
  </div>
</header>

<section>
  <h2>Description</h2>
  <p>This Bash script generates combinations of lowercase letters and digits and checks whether corresponding domains are available under a chosen top-level domain, defaulting to <b>.dk</b>. It queries the official Punktum.dk WHOIS server and classifies each domain as free or taken, writing results to separate files. It respects the recommended rate limit by pausing between lookups.</p>
</section>

<section>
  <h2>Features</h2>
  <ul>
    <li>Custom <b>domain ending</b> (e.g., .dk, .com, .net).</li>
    <li>Configurable <b>rate limit</b> via sleep duration between WHOIS queries.</li>
    <li><b>MIN_LENGTH</b> and <b>MAX_LENGTH</b> define the length range to scan.</li>
    <li>Character set includes <b>a–z</b> and <b>0–9</b>.</li>
    <li>Recursive generator produces combinations without manual nested loops.</li>
    <li>Writes <b>free</b> and <b>taken</b> domains to separate, length-annotated files.</li>
    <li>Progress messages while scanning different lengths.</li>
  </ul>
</section>

<section>
  <h2>How It Works</h2>
  <ol>
    <li>Builds all candidate labels using lowercase letters and digits within the configured length range.</li>
    <li>For each label, performs WHOIS against the Danish registry server:
      <pre><code>whois -h whois.punktum.dk example.dk</code></pre>
    </li>
    <li>If the response contains <code>No entries found for the selected source.</code>, the domain is treated as free; otherwise taken.</li>
    <li>Results are appended to two files for later review.</li>
    <li>A sleep interval enforces one request per second by default.</li>
  </ol>
</section>

<section>
  <h2>Configuration</h2>
  <table>
    <thead>
      <tr><th>Variable</th><th>Purpose</th><th>Example</th></tr>
    </thead>
    <tbody>
      <tr><td><code>DOMAIN_ENDING</code></td><td>TLD suffix to check</td><td><code>.dk</code></td></tr>
      <tr><td><code>SLEEP_TIME</code></td><td>Seconds to wait between WHOIS queries</td><td><code>1</code></td></tr>
      <tr><td><code>MIN_LENGTH</code></td><td>Shortest label length to include</td><td><code>1</code></td></tr>
      <tr><td><code>MAX_LENGTH</code></td><td>Longest label length to include</td><td><code>3</code></td></tr>
    </tbody>
  </table>

  <div class="grid">
    <div>
      <h3>Default: 1–3 char .dk at 1 req/s</h3>
      <pre><code>DOMAIN_ENDING=".dk"
SLEEP_TIME=1
MIN_LENGTH=1
MAX_LENGTH=3</code></pre>
    </div>
    <div>
      <h3>Only 2-char .dk</h3>
      <pre><code>DOMAIN_ENDING=".dk"
SLEEP_TIME=1
MIN_LENGTH=2
MAX_LENGTH=2</code></pre>
    </div>
  </div>
</section>

<section>
  <h2>Script</h2>
  <pre><code>#!/bin/bash
DOMAIN_ENDING=".dk"
SLEEP_TIME=1
MIN_LENGTH=1
MAX_LENGTH=3
letters=({a..z} {0..9})
output_free="free_domains_${MIN_LENGTH}-${MAX_LENGTH}char.txt"
output_taken="taken_domains_${MIN_LENGTH}-${MAX_LENGTH}char.txt"
&gt; "$output_free"
&gt; "$output_taken"
check_domain() {
    domain="$1$DOMAIN_ENDING"
    result=$(whois -h whois.punktum.dk "$domain" 2&gt;/dev/null)
    if echo "$result" | grep -q "No entries found for the selected source."; then
        echo "[FREE]  $domain"
        echo "$domain" &gt;&gt; "$output_free"
    else
        echo "[TAKEN] $domain"
        echo "$domain" &gt;&gt; "$output_taken"
    fi
    sleep "$SLEEP_TIME"
}
generate_domains() {
    for ((len=MIN_LENGTH; len&lt;=MAX_LENGTH; len++)); do
        echo "Checking ${len}-character domains..."
        generate_combinations "" $len
    done
}
generate_combinations() {
    local prefix=$1
    local remaining=$2
    if (( remaining == 0 )); then
        check_domain "$prefix"
        return
    fi
    for ch in "${letters[@]}"; do
        generate_combinations "$prefix$ch" $((remaining - 1))
    done
}
generate_domains
echo "Done. Free domains: $output_free, taken domains: $output_taken."</code></pre>
</section>

<section>
  <h2>How To Run</h2>
  <ol>
    <li>Create a file named <code>check_domains.sh</code> and paste the script content into it.</li>
    <li>Make it executable:
      <pre><code>chmod +x check_domains.sh</code></pre>
    </li>
    <li>Run it:
      <pre><code>./check_domains.sh</code></pre>
    </li>
    <li>Watch the terminal for status lines and review the output files:
      <ul>
        <li><code>free_domains_[MIN]-[MAX]char.txt</code></li>
        <li><code>taken_domains_[MIN]-[MAX]char.txt</code></li>
      </ul>
    </li>
  </ol>
</section>

<section class="note">
  <h2>Notes</h2>
  <ul>
    <li>Punktum.dk recommends a maximum of one WHOIS request per second; keep <code>SLEEP_TIME=1</code>.</li>
    <li>For quick tests, run only length 1 or 2 by narrowing the range.</li>
    <li>The character set is lowercase a–z and digits 0–9. Adjust as needed before scanning.</li>
  </ul>
</section>

<footer>
  <p>&copy; .dk Domain Checker Guide</p>
</footer>

</body>
</html>
