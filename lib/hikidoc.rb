# Copyright (c) 2005, Kazuhiko <kazuhiko@fdiary.net>
# Copyright (c) 2007 Minero Aoki
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of the HikiDoc nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "stringio"
require "strscan"
require "uri"
begin
  require "syntax/convertors/html"
rescue LoadError
end

class HikiDoc
  VERSION = "0.0.1" # FIXME
  Revision = %q$Rev$ # Is it needed?

  def HikiDoc.to_html(src, options = {})
    new(HTMLOutput.new(">"), options).compile(src)
  end

  def HikiDoc.to_xhtml(src, options = {})
    new(HTMLOutput.new(" />"), options).compile(src)
  end

  def initialize(output, options = {})
    @output = output
    @options = default_options.merge(options)
    @header_re = nil
    @level = options[:level] || 1
    @plugin_syntax = options[:plugin_syntax] || method(:valid_plugin_syntax?)
  end

  def compile(src)
    @output.reset
    escape_plugin_blocks(src) {|escaped|
      compile_blocks escaped
      @output.string
    }
  end

  # for backward compatibility
  def to_html
    $stderr.puts("warning: HikiDoc#to_html is deprecated. Please use HikiDoc.to_html or HikiDoc.to_xhtml instead.")
    self.class.to_html(@output, @options)
  end

  private

  def default_options
    {
      :allow_bracket_inline_image => true,
      :use_wiki_name => true,
    }
  end

  #
  # Plugin
  #

  def valid_plugin_syntax?(code)
    /['"]/ !~ code.gsub(/'(?:[^\\']+|\\.)*'|"(?:[^\\"]+|\\.)*"/m, "")
  end

  def escape_plugin_blocks(text)
    s = StringScanner.new(text)
    buf = ""
    @plugin_blocks = []
    while chunk = s.scan_until(/\{\{/)
      tail = chunk[-2, 2]
      chunk[-2, 2] = ""
      buf << chunk
      # plugin
      if block = extract_plugin_block(s)
        @plugin_blocks.push block
        buf << "\0#{@plugin_blocks.size - 1}\0"
      else
        buf << "{{"
      end
    end
    buf << s.rest
    buf = yield(buf)
    buf.gsub(/\0(\d+)\0/) {
      @output.inline_plugin(plugin_block($1.to_i))
    }
  end

  def restore_plugin_block(str)
    str.gsub(/\0(\d+)\0/) {
      "{{" + plugin_block($1.to_i) + "}}"
    }
  end

  def plugin_block(id)
    @plugin_blocks[id] or raise "must not happen: #{id.inspect}"
  end

  def extract_plugin_block(s)
    pos = s.pos
    buf = ""
    while chunk = s.scan_until(/\}\}/)
      buf << chunk
      buf.chomp!("}}")
      if @plugin_syntax.call(buf)
        return buf
      end
      buf << "}}"
    end
    s.pos = pos
    nil
  end

  #
  # Block Level
  #

  def compile_blocks(src)
    f = LineInput.new(StringIO.new(src))
    while line = f.peek
      case line
      when COMMENT_RE
        f.gets
      when HEADER_RE
        compile_header f.gets
      when HRULE_RE
        f.gets
        compile_hrule
      when LIST_RE
        compile_list f
      when DLIST_RE
        compile_dlist f
      when TABLE_RE
        compile_table f
      when BLOCKQUOTE_RE
        compile_blockquote f
      when INDENTED_PRE_RE
        compile_indented_pre f
      when BLOCK_PRE_OPEN_RE
        compile_block_pre f
      else
        if /^$/ =~ line
          f.gets
          next
        end
        compile_paragraph f
      end
    end
  end

  COMMENT_RE = %r<\A//>

  def skip_comments(f)
    f.while_match(COMMENT_RE) do |line|
    end
  end

  HEADER_RE = /\A!+/

  def compile_header(line)
    @header_re ||= /\A!{1,#{7 - @level}}/
    level = @level + (line.slice!(@header_re).size - 1)
    title = strip(line)
    @output.headline level, compile_inline(title)
  end

  HRULE_RE = /\A----$/

  def compile_hrule
    @output.hrule
  end

  ULIST = "*"
  OLIST = "#"
  LIST_RE = /\A#{Regexp.union(ULIST, OLIST)}+/

  def compile_list(f)
    typestack = []
    level = 0
    @output.list_begin
    f.while_match(LIST_RE) do |line|
      list_type = (line[0,1] == ULIST ? "ul" : "ol")
      new_level = line.slice(LIST_RE).size
      item = strip(line.sub(LIST_RE, ""))
      if new_level > level
        (new_level - level).times do
          typestack.push list_type
          @output.list_open list_type
          @output.listitem_open
        end
        @output.listitem compile_inline(item)
      elsif new_level < level
        (level - new_level).times do
          @output.listitem_close
          @output.list_close typestack.pop
        end
        @output.listitem_close
        @output.listitem_open
        @output.listitem compile_inline(item)
      elsif list_type == typestack.last
        @output.listitem_close
        @output.listitem_open
        @output.listitem compile_inline(item)
      else
        @output.listitem_close
        @output.list_close typestack.pop
        @output.list_open list_type
        @output.listitem_open
        @output.listitem compile_inline(item)
        typestack.push list_type
      end
      level = new_level
      skip_comments f
    end
    level.times do
      @output.listitem_close
      @output.list_close typestack.pop
    end
    @output.list_end
  end

  DLIST_RE = /\A:/

  def compile_dlist(f)
    @output.dlist_open
    f.while_match(DLIST_RE) do |line|
      dt, dd = split_dlitem(line.sub(DLIST_RE, ""))
      @output.dlist_item compile_inline(dt), compile_inline(dd)
      skip_comments f
    end
    @output.dlist_close
  end

  def split_dlitem(line)
    re = /\A((?:#{BRACKET_LINK_RE}|.)*?):/o
    if m = re.match(line)
      return m[1], m.post_match
    else
      return line, ""
    end
  end

  TABLE_RE = /\A\|\|/

  def compile_table(f)
    lines = []
    f.while_match(TABLE_RE) do |line|
      lines.push line
      skip_comments f
    end
    @output.table_open
    lines.each do |line|
      @output.table_record_open
      split_columns(line.sub(TABLE_RE, "")).each do |col|
        mid = col.sub!(/\A!/, "") ? "table_head" : "table_data"
        span = col.slice!(/\A[\^>]*/)
        rs = span_count(span, "^")
        cs = span_count(span, ">")
        @output.__send__(mid, compile_inline(col), rs, cs)
      end
      @output.table_record_close
    end
    @output.table_close
  end

  def split_columns(str)
    cols = str.split(/\|\|/)
    cols.pop if cols.last.chomp.empty?
    cols
  end

  def span_count(str, ch)
    c = str.count(ch)
    c == 0 ? nil : c + 1
  end

  BLOCKQUOTE_RE = /\A""[ \t]?/

  def compile_blockquote(f)
    @output.blockquote_open
    lines = []
    f.while_match(BLOCKQUOTE_RE) do |line|
      lines.push line.sub(BLOCKQUOTE_RE, "")
      skip_comments f
    end
    compile_blocks lines.join("")
    @output.blockquote_close
  end

  INDENTED_PRE_RE = /\A[ \t]/

  def compile_indented_pre(f)
    lines = f.span(INDENTED_PRE_RE)\
        .map {|line| rstrip(line.sub(INDENTED_PRE_RE, "")) }\
        .map {|line| @output.text(line) }
    @output.preformatted restore_plugin_block(lines.join("\n"))
  end

  BLOCK_PRE_OPEN_RE = /\A<<<\s*(\w+)?/
  BLOCK_PRE_CLOSE_RE = /\A>>>/

  def compile_block_pre(f)
    m = BLOCK_PRE_OPEN_RE.match(f.gets) or raise "must not happen"
    syntax = m[1] ? m[1].downcase : nil
    str = restore_plugin_block(f.break(BLOCK_PRE_CLOSE_RE).join.chomp)
    f.gets
    if syntax
      begin
        convertor = Syntax::Convertors::HTML.for_syntax(syntax)
        @output.puts_html convertor.convert(str)
      rescue NameError, RuntimeError
        @output.preformatted @output.text(str)
      end
    else
      @output.preformatted @output.text(str)
    end
  end

  BLANK = /\A$/
  PARAGRAPH_END_RE = Regexp.union(BLANK,
                                  HEADER_RE, HRULE_RE, LIST_RE, DLIST_RE,
                                  BLOCKQUOTE_RE, TABLE_RE,
                                  INDENTED_PRE_RE, BLOCK_PRE_OPEN_RE)

  def compile_paragraph(f)
    str = f.break(PARAGRAPH_END_RE)\
        .reject {|line| COMMENT_RE =~ line }\
        .map {|line| compile_inline(strip(line)) }\
        .join("\n")
    if /\A\0(\d+)\0\z/ =~ str
      @output.block_plugin plugin_block($1.to_i)
    else
      @output.paragraph str
    end
  end

  #
  # Inline Level
  #

  BRACKET_LINK_RE = /\[\[.+\]\]/
  URI_RE = /(?:https?|ftp|file|mailto):[A-Za-z0-9;\/?:@&=+$,\-_.!~*\'()#%]+/
  WIKI_NAME_RE = /\b(?:[A-Z]+[a-z\d]+){2,}\b/

  def compile_inline(str)
    re = / (#{BRACKET_LINK_RE})
         | (#{URI_RE})
         | (#{MODIFIER_RE})
         | (#{WIKI_NAME_RE})
         /xo
    buf = ""
    while m = re.match(str)
      buf << @output.text(m.pre_match)
      case
      when link = m[1]
        buf << compile_bracket_link(link[2...-2])
      when uri = m[2]
        buf << compile_uri_autolink(uri)
      when mod = m[3]
        buf << compile_modifier(mod)
      when wiki_name = m[4]
        if @options[:use_wiki_name]
          buf << @output.wiki_name(wiki_name)
        else
          buf << @output.text(wiki_name)
        end
      else
        raise "must not happen"
      end
      str = m.post_match
    end
    buf << @output.text(str)
    buf
  end

  def compile_bracket_link(link)
    if m = /\A(?>[^|\\]+|\\.)*\|/.match(link)
      title = m[0].chop
      uri = m.post_match
      fixed_uri = fix_uri(uri)
      if can_image_link?(uri)
        @output.image_hyperlink(fixed_uri, title)
      else
        @output.hyperlink(fixed_uri, compile_modifier(title))
      end
    else
      fixed_link = fix_uri(link)
      if can_image_link?(link)
        @output.image_hyperlink(fixed_link)
      else
        @output.hyperlink(fixed_link, @output.text(link))
      end
    end
  end

  def can_image_link?(uri)
    image?(uri) and @options[:allow_bracket_inline_image]
  end

  def compile_uri_autolink(uri)
    if image?(uri)
      @output.image_hyperlink(fix_uri(uri))
    else
      @output.hyperlink(fix_uri(uri), uri)
    end
  end

  def fix_uri(uri)
    if %r|://| !~ uri and /\Amailto:/ !~ uri
      uri.sub(/\A\w+:/, "")
    else
      uri
    end
  end

  IMAGE_EXTS = %w(.jpg .jpeg .gif .png)

  def image?(uri)
    IMAGE_EXTS.include?(File.extname(uri).downcase)
  end

  STRONG = "'''"
  EM = "''"
  DEL = "=="

  STRONG_RE = /'''.+?'''/
  EM_RE     = /''.+?''/
  DEL_RE    = /==.+?==/

  MODIFIER_RE = Regexp.union(STRONG_RE, EM_RE, DEL_RE)

  MODTAG = {
    STRONG => "strong",
    EM     => "em",
    DEL    => "del"
  }

  def compile_modifier(str)
    buf = ""
    while m = / (#{MODIFIER_RE})
              /xo.match(str)
      buf << @output.text(m.pre_match)
      case
      when chunk = m[1]
        mod, s = split_mod(chunk)
        mid = MODTAG[mod]
        buf << @output.__send__(mid, compile_modifier(s))
      else
        raise "must not happen"
      end
      str = m.post_match
    end
    buf << @output.text(str)
    buf
  end

  def split_mod(str)
    case str
    when /\A'''/
      return str[0, 3], str[3...-3]
    when /\A''/
      return str[0, 2], str[2...-2]
    when /\A==/
      return str[0, 2], str[2...-2]
    else
      raise "must not happen: #{str.inspect}"
    end
  end

  def strip(str)
    rstrip(lstrip(str))
  end

  def rstrip(str)
    str.sub(/[ \t\r\n\v\f]+\z/, "")
  end

  def lstrip(str)
    str.sub(/\A[ \t\r\n\v\f]+/, "")
  end


  class HTMLOutput
    def initialize(suffix = " />")
      @suffix = suffix
      @f = nil
    end

    def reset
      @f = StringIO.new
    end

    def string
      @f.string
    end

    #
    # Procedures
    #

    def headline(level, title)
      @f.puts "<h#{level}>#{title}</h#{level}>"
    end

    def hrule
      @f.puts "<hr#{@suffix}"
    end

    def list_begin
    end

    def list_end
      @f.puts
    end

    def list_open(type)
      @f.puts "<#{type}>"
    end

    def list_close(type)
      @f.print "</#{type}>"
    end

    def listitem_open
      @f.print "<li>"
    end

    def listitem_close
      @f.puts "</li>"
    end

    def listitem(item)
      @f.print item
    end

    def dlist_open
      @f.puts "<dl>"
    end

    def dlist_close
      @f.puts "</dl>"
    end

    def dlist_item(dt, dd)
      case
      when dd.empty?
        @f.puts "<dt>#{dt}</dt>"
      when dt.empty?
        @f.puts "<dd>#{dd}</dd>"
      else
        @f.puts "<dt>#{dt}</dt>"
        @f.puts "<dd>#{dd}</dd>"
      end
    end

    def table_open
      @f.puts %Q(<table border="1">)
    end

    def table_close
      @f.puts "</table>"
    end

    def table_record_open
      @f.print "<tr>"
    end

    def table_record_close
      @f.puts "</tr>"
    end

    def table_head(item, rs, cs)
      @f.print "<th#{tdattr(rs, cs)}>#{item}</th>"
    end

    def table_data(item, rs, cs)
      @f.print "<td#{tdattr(rs, cs)}>#{item}</td>"
    end

    def tdattr(rs, cs)
      buf = ""
      buf << %Q( rowspan="#{rs}") if rs
      buf << %Q( colspan="#{cs}") if cs
      buf
    end
    private :tdattr

    def blockquote_open
      @f.print "<blockquote>"
    end

    def blockquote_close
      @f.puts "</blockquote>"
    end

    def preformatted(str)
      @f.print "<pre>"
      @f.print str
      @f.puts "</pre>"
    end

    def paragraph(str)
      @f.puts "<p>#{str}</p>"
    end

    def block_plugin(str)
      @f.puts %Q(<div class="plugin">{{#{escape_html(str)}}}</div>)
    end

    def puts_html(str)
      @f.puts str
    end

    #
    # Functions
    #

    def hyperlink(uri, title)
      %Q(<a href="#{escape_html_param(uri)}">#{title}</a>)
    end

    def wiki_name(name)
      hyperlink(name, text(name))
    end

    def image_hyperlink(uri, alt=nil)
      alt ||= uri.split(/\//).last
      alt = escape_html(alt)
      %Q(<img src="#{escape_html_param(uri)}" alt="#{alt}"#{@suffix})
    end

    def strong(item)
      "<strong>#{item}</strong>"
    end

    def em(item)
      "<em>#{item}</em>"
    end

    def del(item)
      "<del>#{item}</del>"
    end

    def text(str)
      escape_html(str)
    end

    def inline_plugin(src)
      %Q(<span class="plugin">{{#{src}}}</span>)
    end

    #
    # Utilities
    #

    def escape_html_param(str)
      escape_quote(escape_html(str))
    end

    def escape_html(text)
      text.gsub(/&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
    end

    def unescape_html(text)
      text.gsub(/&gt;/, ">").gsub(/&lt;/, "<").gsub(/&amp;/, "&")
    end

    def escape_quote(text)
      text.gsub(/"/, "&quot;")
    end
  end


  class LineInput
    def initialize(f)
      @input = f
      @buf = []
      @lineno = 0
      @eof_p = false
    end

    def inspect
      "\#<#{self.class} file=#{@input.inspect} line=#{lineno()}>"
    end

    def eof?
      @eof_p
    end

    def lineno
      @lineno
    end

    def gets
      unless @buf.empty?
        @lineno += 1
        return @buf.pop
      end
      return nil if @eof_p   # to avoid ARGF blocking.
      line = @input.gets
      line = line.sub(/\r\n/, "\n") if line
      @eof_p = line.nil?
      @lineno += 1
      line
    end

    def ungets(line)
      return unless line
      @lineno -= 1
      @buf.push line
      line
    end

    def peek
      line = gets()
      ungets line if line
      line
    end

    def next?
      peek() ? true : false
    end

    def skip_blank_lines
      n = 0
      while line = gets()
        unless line.strip.empty?
          ungets line
          return n
        end
        n += 1
      end
      n
    end

    def gets_if(re)
      line = gets()
      if not line or not (re =~ line)
        ungets line
        return nil
      end
      line
    end

    def gets_unless(re)
      line = gets()
      if not line or re =~ line
        ungets line
        return nil
      end
      line
    end

    def each
      while line = gets()
        yield line
      end
    end

    def while_match(re)
      while line = gets()
        unless re =~ line
          ungets line
          return
        end
        yield line
      end
      nil
    end

    def getlines_while(re)
      buf = []
      while_match(re) do |line|
        buf.push line
      end
      buf
    end

    alias span getlines_while   # from Haskell

    def until_match(re)
      while line = gets()
        if re =~ line
          ungets line
          return
        end
        yield line
      end
      nil
    end

    def getlines_until(re)
      buf = []
      until_match(re) do |line|
        buf.push line
      end
      buf
    end

    alias break getlines_until   # from Haskell

    def until_terminator(re)
      while line = gets()
        return if re =~ line   # discard terminal line
        yield line
      end
      nil
    end

    def getblock(term_re)
      buf = []
      until_terminator(term_re) do |line|
        buf.push line
      end
      buf
    end
  end
end

if __FILE__ == $0
  puts HikiDoc.to_html(ARGF.read(nil))
end
