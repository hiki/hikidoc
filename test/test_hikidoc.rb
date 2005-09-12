# $Id:$
require 'test/unit'

rootdir = "#{File::dirname($0)}/.."
require "#{rootdir}/lib/hikidoc"

class HikiDocTest < HikiDoc
  public :escape_html, :unescape_html, :escape_meta_char
end

class HikiDoc_Unit_Tests < Test::Unit::TestCase

  # test private methods

  def test_escape_html
    assert_equal( 'a&amp;b', HikiDocTest.new.escape_html( 'a&b' ) )
    assert_equal( 'a&lt;&lt;b', HikiDocTest.new.escape_html( 'a<<b' ) )
    assert_equal( 'a&gt;&gt;b', HikiDocTest.new.escape_html( 'a>>b' ) )
  end

  def test_unescape_html
    assert_equal( 'a&b', HikiDocTest.new.unescape_html( 'a&amp;b' ) )
    assert_equal( 'a<<b', HikiDocTest.new.unescape_html( 'a&lt;&lt;b' ) )
    assert_equal( 'a>>b', HikiDocTest.new.unescape_html( 'a&gt;&gt;b' ) )
  end

  def test_escape_meta_char
    assert_equal( 'a&#x3a;b', HikiDocTest.new.escape_meta_char( 'a\:b' ) )
    assert_equal( 'a&#x22;b', HikiDocTest.new.escape_meta_char( 'a\"b' ) )
    assert_equal( 'a&#x7c;b', HikiDocTest.new.escape_meta_char( 'a\|b' ) )
    assert_equal( 'a&#x27;b', HikiDocTest.new.escape_meta_char( "a\\'b" ) )
  end

  # test 'to_html'

  def test_plugin
    assert_equal( %Q|<div class="plugin">{{hoge}}</div>\n|, HikiDoc.new( '{{hoge}}' ).to_html )
    assert_equal( %Q|<p>a<span class="plugin">{{hoge}}</span>b</p>\n|, HikiDoc.new( 'a{{hoge}}b' ).to_html )
    assert_equal( %Q|<p>a{{hoge</p>\n|, HikiDoc.new( 'a{{hoge' ).to_html )
    assert_equal( %Q|<p>hoge}}b</p>\n|, HikiDoc.new( 'hoge}}b' ).to_html )
    assert_equal( %Q|<div class="plugin">{{hoge(\"}}\")}}</div>\n|, HikiDoc.new( '{{hoge("}}")}}' ).to_html )
    assert_equal( %Q|<p><span class="plugin">{{hoge}}</span>\na</p>\n|, HikiDoc.new( "{{hoge}}\na" ).to_html )
    assert_equal( %Q|<div class="plugin">{{hoge}}</div>\n<p>a</p>\n|, HikiDoc.new( "{{hoge}}\n\na" ).to_html )
  end

  def test_blockquote
    assert_equal( "<blockquote>\n<p>hoge</p>\n</blockquote>\n", HikiDoc.new( %Q|""hoge\n| ).to_html )
    assert_equal( "<blockquote>\n<p>hoge\nfuga</p>\n</blockquote>\n", HikiDoc.new( %Q|""hoge\n""fuga\n| ).to_html )
    assert_equal( "<blockquote>\n<p>hoge</p>\n<blockquote>\n<p>fuga</p>\n</blockquote>\n</blockquote>\n", HikiDoc.new( %Q|""hoge\n"" ""fuga\n| ).to_html )
    assert_equal( "<blockquote>\n<h1>hoge</h1>\n</blockquote>\n", HikiDoc.new( %Q|"" ! hoge\n| ).to_html )
    assert_equal( "<blockquote>\n<p>foo\nbar</p>\n<p>foo</p>\n</blockquote>\n", HikiDoc.new( %Q|""foo\n""bar\n""\n""foo| ).to_html )
    assert_equal( "<blockquote>\n<p>foo\nbar</p>\n<h1>foo</h1>\n</blockquote>\n", HikiDoc.new( %Q|""foo\n""bar\n""!foo| ).to_html )
    assert_equal( "<blockquote>\n<p>foo\nbar</p>\n<pre>\nbaz\n</pre>\n</blockquote>\n", HikiDoc.new( %Q|""foo\n"" bar\n""  baz| ).to_html )
    assert_equal( "<blockquote>\n<p>foo\nbar</p>\n<pre>\nbaz\n</pre>\n</blockquote>\n", HikiDoc.new( %Q|""foo\n""\tbar\n""\t\tbaz| ).to_html )
  end

  def test_header
    assert_equal( "<h1>hoge</h1>\n", HikiDoc.new( "!hoge" ).to_html )
    assert_equal( "<h2>hoge</h2>\n", HikiDoc.new( "!! hoge" ).to_html )
    assert_equal( "<h3>hoge</h3>\n", HikiDoc.new( "!!!hoge" ).to_html )
    assert_equal( "<h4>hoge</h4>\n", HikiDoc.new( "!!!! hoge" ).to_html )
    assert_equal( "<h5>hoge</h5>\n", HikiDoc.new( "!!!!!hoge" ).to_html )
    assert_equal( "<h6>hoge</h6>\n", HikiDoc.new( "!!!!!! hoge" ).to_html )
    assert_equal( "<h6>! hoge</h6>\n", HikiDoc.new( "!!!!!!! hoge" ).to_html )
    assert_equal( "<h1>foo</h1>\n<h2>bar</h2>\n", HikiDoc.new( "!foo\n!!bar" ).to_html )
  end

  def test_list
    assert_equal( "<ul>\n<li>foo</li>\n</ul>\n", HikiDoc.new( "* foo" ).to_html )
    assert_equal( "<ul>\n<li>foo</li>\n<li>bar</li>\n</ul>\n", HikiDoc.new( "* foo\n* bar" ).to_html )
    assert_equal( "<ul>\n<li>foo<ul>\n<li>bar</li>\n</ul>\n</li>\n</ul>\n", HikiDoc.new( "* foo\n** bar" ).to_html )
    assert_equal( "<ul>\n<li>foo<ul>\n<li>foo</li>\n</ul>\n</li>\n<li>bar</li>\n</ul>\n", HikiDoc.new( "* foo\n** foo\n* bar" ).to_html )
    assert_equal( "<ul>\n<li>foo<ul>\n<li>foo</li>\n</ul>\n</li>\n<li>bar</li>\n</ul>\n", HikiDoc.new( "* foo\n*** foo\n* bar" ).to_html )
    assert_equal( "<ul>\n<li>foo<ol>\n<li>foo</li>\n</ol>\n</li>\n<li>bar</li>\n</ul>\n", HikiDoc.new( "* foo\n## foo\n* bar" ).to_html )
    assert_equal( "<ul>\n<li>foo</li>\n</ul>\n<ol>\n<li>bar</li>\n</ol>\n", HikiDoc.new( "* foo\n# bar" ).to_html )
  end

  def test_hrules
    assert_equal( "<hr />\n", HikiDoc.new( "----" ).to_html )
    assert_equal( "<p>----a</p>\n", HikiDoc.new( "----a" ).to_html )
  end

  def test_pre
    assert_equal( "<pre>\nfoo\n</pre>\n", HikiDoc.new( " foo" ).to_html )
    assert_equal( "<pre>\n\\:\n</pre>\n", HikiDoc.new( ' \:' ).to_html )
    assert_equal( "<pre>\nfoo\n</pre>\n", HikiDoc.new( "\tfoo" ).to_html )
  end

  def test_multi_pre
    assert_equal( "<pre>\nfoo\n</pre>\n", HikiDoc.new( "<<<\nfoo\n>>>" ).to_html )
    assert_equal( "<pre>\nfoo\n bar\n</pre>\n", HikiDoc.new( "<<<\nfoo\n bar\n>>>" ).to_html )
    assert_equal( "<pre>\nfoo\n</pre>\n<pre>\nbar\n</pre>\n", HikiDoc.new( "<<<\nfoo\n>>>\n<<<\nbar\n>>>" ).to_html )
  end

  def test_comment
    assert_equal( "\n", HikiDoc.new( "// foo" ).to_html )
    assert_equal( "\n", HikiDoc.new( "// foo\n" ).to_html )
  end

  def test_paragraph
    assert_equal( "<p>foo</p>\n", HikiDoc.new( "foo" ).to_html )
  end

  def test_escape
    assert_equal( %Q|<p>""foo</p>\n|, HikiDoc.new( %q|\"\"foo| ).to_html )
  end

  def test_link
    assert_equal( %Q|<p><a href="http://hikiwiki.org/">http://hikiwiki.org/</a></p>\n|, HikiDoc.new( "http://hikiwiki.org/" ).to_html )
    assert_equal( %Q|<p><a href="http://hikiwiki.org/">http://hikiwiki.org/</a></p>\n|, HikiDoc.new( "[[http://hikiwiki.org/]]" ).to_html )
    assert_equal( %Q|<p><a href="http://hikiwiki.org/">Hiki</a></p>\n|, HikiDoc.new( "[[Hiki|http://hikiwiki.org/]]" ).to_html )
    assert_equal( %Q|<p><a href="http://hikiwiki.org/img.png">img</a></p>\n|, HikiDoc.new( "[[img|http://hikiwiki.org/img.png]]" ).to_html )
    assert_equal( %Q|<p><a href="http://hikiwiki.org/img.png">http://hikiwiki.org/img.png</a></p>\n|, HikiDoc.new( "[[http://hikiwiki.org/img.png]]" ).to_html )
    assert_equal( %Q|<p><img src="http://hikiwiki.org/img.png" alt="img.png" /></p>\n|, HikiDoc.new( "http://hikiwiki.org/img.png" ).to_html )
    assert_equal( %Q|<p><a href="%CB%EE">Tuna</a></p>\n|, HikiDoc.new( '[[Tuna|%CB%EE]]' ).to_html )
    assert_equal( %Q|<p><a href="%22">"</a></p>\n|, HikiDoc.new( '[["]]' ).to_html )
    assert_equal( %Q|<p><a href="%22">%22</a></p>\n|, HikiDoc.new( '[[%22]]' ).to_html )
    assert_equal( %Q|<p><a href="%26">&amp;</a></p>\n|, HikiDoc.new( '[[&]]' ).to_html )
  end

  def test_definition
    assert_equal( "<dl>\n<dt>a</dt><dd>b</dd>\n</dl>\n", HikiDoc.new( ":a:b" ).to_html )
    assert_equal( "<dl>\n<dt>a</dt><dd>b</dd>\n<dd>c</dd>\n</dl>\n", HikiDoc.new( ":a:b\n::c" ).to_html )
    assert_equal( "<dl>\n<dt>a:b</dt><dd>c</dd>\n</dl>\n", HikiDoc.new( ':a\:b:c' ).to_html )
    assert_equal( "<dl>\n<dt>a</dt><dd>b:c</dd>\n</dl>\n", HikiDoc.new( ':a:b:c' ).to_html )
  end

  def test_definition_with_link
    assert_equal( %Q|<dl>\n<dt><a href="http://hikiwiki.org/">Hiki</a></dt><dd>Website</dd>\n</dl>\n|, HikiDoc.new( ':[[Hiki|http://hikiwiki.org/]]:Website' ).to_html )
  end

  def test_definition_with_modifier
    assert_equal( %Q|<dl>\n<dt><strong>foo</strong></dt><dd>bar</dd>\n</dl>\n|, HikiDoc.new( ":'''foo''':bar" ).to_html )
  end

  def test_table
    assert_equal( %Q|<table border=\"1\">\n<tr><td>a</td><td>b</td></tr>\n</table>\n|, HikiDoc.new( "||a||b" ).to_html )
    assert_equal( %Q|<table border=\"1\">\n<tr><td>a</td><td>b</td></tr>\n</table>\n|, HikiDoc.new( "||a||b||" ).to_html )
    assert_equal( %Q|<table border=\"1\">\n<tr><td>a</td><td>b</td><td> </td></tr>\n</table>\n|, HikiDoc.new( "||a||b|| " ).to_html )
    assert_equal( %Q|<table border=\"1\">\n<tr><th>a</th><td>b</td></tr>\n</table>\n|, HikiDoc.new( "||!a||b||" ).to_html )
    assert_equal( %Q|<table border=\"1\">\n<tr><td colspan=\"2\">1</td><td rowspan=\"2\">2</td></tr>\n<tr><td rowspan=\"2\">3</td><td>4</td></tr>\n<tr><td colspan=\"2\">5</td></tr>\n</table>\n|, HikiDoc.new( "||>1||^2\n||^3||4\n||>5" ).to_html )
  end

  def test_table_with_modifier
    assert_equal( %Q!<table border=\"1\">\n<tr><td><strong>||</strong></td><td>bar</td></tr>\n</table>\n!, HikiDoc.new( "||'''||'''||bar" ).to_html )
  end

  def test_modifier
    assert_equal( "<p><strong>foo</strong></p>\n", HikiDoc.new( "'''foo'''" ).to_html )
    assert_equal( "<p><em>foo</em></p>\n", HikiDoc.new( "''foo''" ).to_html )
    assert_equal( "<p><del>foo</del></p>\n", HikiDoc.new( "==foo==" ).to_html )
    assert_equal( "<p><em>foo==bar</em>baz==</p>\n", HikiDoc.new( "''foo==bar''baz==" ).to_html )
  end

  def test_modifier_and_link
    assert_equal( %Q|<p><a href="http://hikiwiki.org/"><strong>Hiki</strong></a></p>\n|, HikiDoc.new( "[['''Hiki'''|http://hikiwiki.org/]]" ).to_html )
  end

  def test_pre_and_plugin
    assert_equal( %Q|<pre>\n{{hoge}}\n</pre>\n|, HikiDoc.new( ' {{hoge}}').to_html )
    assert_equal( %Q|<pre>\n{{hoge}}\n</pre>\n|, HikiDoc.new( "<<<\n{{hoge}}\n>>>").to_html )
    assert_equal( %Q|<div class=\"plugin\">{{foo\n 1}}</div>\n|, HikiDoc.new( "{{foo\n 1}}").to_html )
  end
end
