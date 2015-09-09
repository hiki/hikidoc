# Paragraphs

Consecutive lines are concatenated into a single paragraph.

Blank lines (ones with only a carriage return or with only spaces and tabs) mark the end of a paragraph.

* Example statement

```
For example,
if I write like this, these lines
will be formatted as one paragraph.
```

* Example output

<p>For example,
if I write like this, these lines
will be formatted as one paragraph.</p>

# Links

## [WikiNames](WikiNames)

[WikiNames](WikiNames) are comprised of two or more words put together; each word begins with an uppercase letter, and is followed by at least one lowercase letter or number.

Words in which this condition is met become a [WikiName](WikiName), and a link is automatically attached.

* Example statement

```
WikiName     - WikiName
HogeRule1    - WikiName
NOTWIKINAME  - All of the letters are uppercase, so this is not a WikiName
WikiNAME     - All of the letters in NAME are uppercase, so this is not a WikiName
fooWikiName  - This begins with "foo", which is in all lowercase, so this is not a WikiName
```

* Example output

<ul>
<li><ul>
<li><a href="WikiName">WikiName</a>     - <a href="WikiName">WikiName</a></li>
<li><a href="HogeRule1">HogeRule1</a>    - <a href="WikiName">WikiName</a></li>
<li>NOTWIKINAME  - All of the letters are uppercase, so this is not a <a href="WikiName">WikiName</a></li>
<li>WikiNAME     - All of the letters in NAME are uppercase, so this is not a <a href="WikiName">WikiName</a></li>
<li>fooWikiName  - This begins with "foo", which is in all lowercase, so this is not a <a href="WikiName">WikiName</a></li>
</ul></li>
</ul>

You can disable an auto [WikiName](WikiName) link by putting _^_ to the [WikiName](WikiName).

* Example statement

```
WikiName     - WikiName
^WikiName    - Disable WikiName link
```

* Example output

<ul>
<li><ul>
<li><a href="WikiName">WikiName</a>     - <a href="WikiName">WikiName</a></li>
<li>WikiName    - Disable WikiName link    - Disable <a href="WikiName">WikiName</a> link</li>
</ul></li>
</ul>

## Linking to other Wiki pages

If a page name is surrounded with two pairs of brackets, it becomes a link to that page.

* Example statement

```
For example, if you write [[TextFormattingRules]], it becomes a link to that page.
```

* Example output

<p>For example, if you write <a href="TextFormattingRules">TextFormattingRules</a>, it becomes a link to that page.</p>

## Linking to an arbitrary URL

If a phrase and URL, separated by a vertical line, are surrounded with two pairs of brackets, it becomes a link to an arbitrary URL.

* Example statement

```
Links like [[Yahoo!|http://www.yahoo.com/]] are also possible.
```

* Example output

<p>Links like <a href="http://www.yahoo.com/">Yahoo!</a> are also possible.</p>

Text in a paragraph that looks like a URL will automatically become a link.

* Example statement

```
Hiki's home page is http://hikiwiki.org/en/ (English).
```

* Example output

<p>Hiki's home page is <a href="http://hikiwiki.org/en/">http://hikiwiki.org/en/</a> (English).</p>

In this case, if the URL ends with jpg., .jpeg, .png, or .gif, the image is displayed on the page.

* Example statement

```
http://jp.rubyist.net/theme/clover/clover_h1.png
```

* Example output

<p><img src="http://jp.rubyist.net/theme/clover/clover_h1.png" alt="clover_h1.png"></p>

#Preformatted text

Lines beginning with spaces or tabs will be treated as preformatted text.

* Example output

<pre>require 'cgi'

cgi = CGI::new
cgi.header

puts &lt;&lt;EOS
&lt;html&gt;
  &lt;head&gt;
    &lt;title&gt;Hello!&lt;/title&gt;
  &lt;/head&gt;
  &lt;body&gt;
  &lt;p&gt;Hello!&lt;/p&gt;
  &lt;/body&gt;
&lt;/html&gt;
EOS</pre>

# Text decoration

Text surrounded by sets of two single quotes ('') is emphasised.

Text surrounded by sets of three single quotes (''') is strongly emphasised.

Text surrounded by sets of double equal signs (===) is struck out.

Text surrounded by sets of double backquotes (``) is inline literal.

* Example statement

```
If you write like this, it becomes ''emphasised''.
And if you write like this, it becomes '''strongly emphasised'''.
==This is dull, but== And struck-out text is supported, too!
If you write like this, it becomes ``monospaced text``.
```

* Example output

<p>If you write like this, it becomes <em>emphasised</em>.
And if you write like this, it becomes <strong>strongly emphasised</strong>.
<del>This is dull, but</del> And struck-out text is supported, too!
If you write like this, it becomes <tt>monospaced text</tt>.</p>

# Headings

Lines with exclamation marks at the beginning become headings.

One can use up to six exclamation marks; they will be converted to \<h1\> to \<h6\> tags.

* Example statement

```
!Heading1
!!Heading2
!!!Heading3
!!!!Heading4
!!!!!Heading5
```

* Example output

<h1>Heading1</h1>
<h2>Heading2</h2>
<h3>Heading3</h3>
<h4>Heading4</h4>
<h5>Heading5</h5>

# Horizontal lines

Four hyphens at the beginning of the line (----) become a horizontal rule.

* Example statement

```
A B C D E
----
F G H I J
```

* Example output

<p>A B C D E</p>
<hr>
<p>F G H I J</p>

# Lists

Lines beginning with asterisks become list items.

It is possible to use up to three asterisks; it is also possible to create nested lists.

Lines beginning with a # become numbered lists.

* Example statement

```
*Item 1
**Item 1.1
**Item 1.2
***Item 1.2.1
***Item 1.2.2
***Item 1.2.3
**Item 1.3
**Item 1.4
*Item 2
```

```
#Item 1
#Item 2
##Item 2.1
##Item 2.2
##Item 2.3
#Item 3
##Item 3.1
###Item 3.1.1
###Item 3.1.2
```

* Example output

<ul>
<li>Item 1<ul>
<li>Item 1.1</li>
<li>Item 1.2<ul>
<li>Item 1.2.1</li>
<li>Item 1.2.2</li>
<li>Item 1.2.3</li>
</ul></li>
<li>Item 1.3</li>
<li>Item 1.4</li>
</ul></li>
<li>Item 2</li>
</ul>
<ol>
<li>Item 1</li>
<li>Item 2<ol>
<li>Item 2.1</li>
<li>Item 2.2</li>
<li>Item 2.3</li>
</ol></li>
<li>Item 3<ol>
<li>Item 3.1<ol>
<li>Item 3.1.1</li>
<li>Item 3.1.2</li>
</ol></li>
</ol></li>
</ol>

# Quotations

Lines beginning with two double quotes become quotations.

* Example statement

```
""This is a quotation.
""This is another quote.
""This is a continued quote.  When there are consecutive quotations,
""they are displayed as one quote,
""like this.
```

* Example output

<blockquote><p>This is a quotation.
This is another quote.
This is a continued quote.  When there are consecutive quotations,
they are displayed as one quote,
like this.</p>
</blockquote>

# Definitions

Lines beginning with a colon and have a phrase and explanation separated by another colon will become a definition.

* Example statement

```
:ringo:apple
:gorira:gorilla
:rakuda:camel
```

* Example output

<dl>
<dt>ringo</dt>
<dd>apple
</dd>
<dt>gorira</dt>
<dd>gorilla
</dd>
<dt>rakuda</dt>
<dd>camel
</dd>
</dl>

# Tables

Tables begin with two vertical bars.

Leading `!' in a cell means that it is a heading cell.

To concatenate columns or rows, put `\>'(columns) or `^'(rows) at head of
the cell.

* Example statement

```
||!row heading \ column heading||!column A||!column B||!column C||!>column D-E (horizontal concatenation)
||!row 1||A1||B1||^C1-C2 (vertical concatenation)||D1||E1
||!row 2||A2||B2||^>D2-E2-D3-E3 (vertical and horizontal concatenation)
||!row 3||>>A3-C3 (horizontal concatenation)
```

* Example output

<table border="1">
<tr><th>row heading \ column heading</th><th>column A</th><th>column B</th><th>column C</th><th colspan="2">column D-E (horizontal concatenation)
</th></tr>
<tr><th>row 1</th><td>A1</td><td>B1</td><td rowspan="2">C1-C2 (vertical concatenation)</td><td>D1</td><td>E1
</td></tr>
<tr><th>row 2</th><td>A2</td><td>B2</td><td rowspan="2" colspan="2">D2-E2-D3-E3 (vertical and horizontal concatenation)
</td></tr>
<tr><th>row 3</th><td colspan="3">A3-C3 (horizontal concatenation)
</td></tr>
</table>

# Comments

Lines starting with `//' becomes a comment line.
Comment lines is not outputted.

* Example statement

```
 // This is a comment line.
```

* Example output (not displayed)

#Plugins

One can use a plugin by surrounding text with two pairs of brackets.
Multiple lines parameter is supported.
When a line contains plugin only, it becomes a block plugin,
which is not surrounded by \<p\> ... \</p\>.

* Example statement

```
{{recent(3)}}
```

* Example statement of multiple lines

```
{{pre('
...
')}}
```

