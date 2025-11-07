<h1>Domain Availability Checker Script</h1>

<p>This Bash script checks whether domains are <b>available or taken</b> by using both <code>dig</code> (DNS lookup) and <code>whois</code>.  
It works with any top-level domain such as <b>.ai</b>, <b>.io</b>, <b>.com</b>, <b>.net</b>, <b>.dk</b>, or others.  
Before performing a WHOIS query, the script first checks if a domain has an existing A or MX DNS record — if it does, it’s automatically considered <b>taken</b>.  
Only domains without DNS records are checked with WHOIS, which makes the process much faster and reduces rate-limit issues.</p>

<h2>Features</h2>
<ul>
  <li>Works with any domain extension (e.g. .ai, .io, .com, .net, .dk).</li>
  <li>Checks <b>DNS first</b> (A and MX records) for speed — skips WHOIS if the domain resolves.</li>
  <li>Fallback to <b>WHOIS</b> when no DNS records exist.</li>
  <li>Automatically detects free domains based on WHOIS responses such as “No entries found”, “Domain not found”, or “No match”.</li>
  <li>Customizable <b>minimum</b> and <b>maximum length</b> of generated domains.</li>
  <li>Adjustable <b>sleep time</b> between WHOIS lookups (<code>SLEEP_TIME</code>).</li>
  <li>Uses lowercase letters (<code>a–z</code>) and digits (<code>0–9</code>) for domain generation.</li>
  <li>Automatically saves results to two files: one for <b>free</b> and one for <b>taken</b> domains.</li>
  <li>Recursive generation ensures the script handles any length range without editing loops.</li>
</ul>

<h2>How It Works</h2>
<ol>
  <li>The script builds all possible combinations of letters and numbers between the configured <code>MIN_LENGTH</code> and <code>MAX_LENGTH</code>.</li>
  <li>For each domain, it first performs a DNS lookup:
    <pre><code>dig +short example.ai A
dig +short example.ai MX</code></pre>
    If either command returns a record, the domain is marked as <b>[TAKEN - DNS]</b>.</li>
  <li>If no DNS records are found, the script performs a WHOIS lookup:
    <pre><code>whois example.ai</code></pre>
  </li>
  <li>If the WHOIS output contains lines like <code>No entries found</code>, <code>No match</code>, or <code>Domain not found</code>, it is considered <b>available</b>.</li>
  <li>Free and taken domains are written to:
    <ul>
      <li><code>free_domains_[MIN]-[MAX]char.txt</code></li>
      <li><code>taken_domains_[MIN]-[MAX]char.txt</code></li>
    </ul>
  </li>
  <li>Only WHOIS lookups trigger the <code>sleep</code> delay to comply with rate limits, making it efficient and safe.</li>
</ol>

<h2>Configuration</h2>
<p>Edit the configuration section at the top of the script to set your preferences:</p>

<pre><code>DOMAIN_ENDING=".ai"    # Domain ending (.ai, .io, .com, .net, .dk, etc.)
SLEEP_TIME=1           # Seconds to wait between WHOIS lookups
MIN_LENGTH=1           # Minimum length of domain names
MAX_LENGTH=2           # Maximum length of domain names
</code></pre>

<h3>Examples</h3>
<ul>
  <li><b>1–2 character .ai domains:</b><br>
  <code>DOMAIN_ENDING=".ai"</code><br>
  <code>MIN_LENGTH=1</code><br>
  <code>MAX_LENGTH=2</code></li>

  <li><b>2–3 character .io domains:</b><br>
  <code>DOMAIN_ENDING=".io"</code><br>
  <code>MIN_LENGTH=2</code><br>
  <code>MAX_LENGTH=3</code></li>

  <li><b>4-character .com domains with 2-second delay:</b><br>
  <code>DOMAIN_ENDING=".com"</code><br>
  <code>SLEEP_TIME=2</code><br>
  <code>MIN_LENGTH=4</code><br>
  <code>MAX_LENGTH=4</code></li>
</ul>

<h3>Troubleshooting</h3>
<p>If the script doesn’t correctly detect available domains:</p>
<ul>
  <li>Try increasing <code>SLEEP_TIME</code> to avoid WHOIS rate-limit blocking.</li>
  <li>Run a WHOIS query manually on a domain you know is free, e.g.:
    <pre><code>whois longnonexistingdomain.ai</code></pre>
    Then note the exact text it returns when the domain doesn’t exist (e.g. <i>“Domain not found”</i>)  
    and add that phrase to the list of <code>grep</code> patterns in the script:
    <pre><code>grep -qiE "No entries found|Domain not found|No match|NOT FOUND"</code></pre>
  </li>
</ul>

<h2>How to Run</h2>
<ol>
  <li>Copy the script into a new file, for example <code>check_domains.sh</code>.</li>
  <li>Make it executable:
    <pre><code>chmod +x check_domains.sh</code></pre>
  </li>
  <li>Run it:
    <pre><code>./check_domains.sh</code></pre>
  </li>
  <li>Monitor progress in the terminal. You’ll see messages such as:
    <pre><code>[TAKEN - DNS] a1.ai
[FREE] b2.ai
[TAKEN - WHOIS] ab.ai</code></pre>
  </li>
  <li>When complete, review the result files in your working directory:
    <ul>
      <li><code>free_domains_[MIN]-[MAX]char.txt</code></li>
      <li><code>taken_domains_[MIN]-[MAX]char.txt</code></li>
    </ul>
  </li>
</ol>

<h2>Notes</h2>
<ul>
  <li>Each WHOIS server has its own output format. Adjust the <code>grep</code> patterns if your TLD uses different wording for available domains.</li>
  <li>Checking by DNS first avoids unnecessary WHOIS calls and can make the script several times faster.</li>
  <li>For common TLDs like .com, .io, or .ai, expect many results to be taken.</li>
  <li>Be mindful of rate limits. Even with DNS checks, avoid excessive queries in short time spans.</li>
</ul>

<h2>Result</h2>
<p>After the script completes, you’ll have two files:</p>
<ul>
  <li><code>free_domains_[MIN]-[MAX]char.txt</code> — all domains confirmed available.</li>
  <li><code>taken_domains_[MIN]-[MAX]char.txt</code> — all domains already in use (found by DNS or WHOIS).</li>
</ul>

<p>This approach provides a fast, reliable, and safe way to check large batches of domains across any TLD, while minimizing load on WHOIS servers.</p>
