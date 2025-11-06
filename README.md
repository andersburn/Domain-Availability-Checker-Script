This Bash script systematically checks all possible .dk domains consisting of 1, 2, or 3 letters or numbers (a–z, 0–9) to see if they are available.
<br>
It uses the whois command to query each generated domain name and looks for the phrase “No entries found,” which indicates that the domain is free.<br>
<ul>
<li>If a domain is available, it’s written to free_domains.txt.</li>
<li>If a domain is already taken, it’s written to taken_domains.txt.</li>
</ul>
<br>
The script goes through all combinations:
<ul>
<li>Single-character domains (e.g., a.dk, 7.dk)</li>
<li>Two-character domains (e.g., ab.dk, x3.dk)</li>
<li>Three-character domains (e.g., cat.dk, z9r.dk)</li>
</ul><br>
When it finishes, it displays a summary message and stores the categorized results in the two output files.
<br><br>

Put the file somwhere.<br>
Run chmod +x filename.sh on it.<br>
Run it using a terminal.<br>
It'll start from the beginning and work its way through. <br>
It'll make 2 files one with:<br>
taken_domains.txt (so you can see it works)<br>
free_domains.txt (that's the one with the gold).<br>

Change the settings so it works for what you are looking for. 
